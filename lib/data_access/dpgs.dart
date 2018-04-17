import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/data_access/FirebaseAccess.dart';
import 'package:FlutterBARD/values/Matchup.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tuple/tuple.dart';

Future<Document> _fetchResource(Uri uri) async {
  try {
    final request = await new HttpClient().getUrl(uri);
    final response = await request.close();
    final body = await response.transform(const Utf8Codec().decoder).join();
    return parse(body);
  } catch (e) {
    return _fetchResource(uri);
  }
}

Future<Document> _postResource(Uri uri) async {
  try {
    final post = await new HttpClient().postUrl(uri);
    final response = await post.close();
    final body = await response.transform(const Utf8Codec().decoder).join();
    return parse(body);
  } catch (e) {
    return _postResource(uri);
  }
}

Future<Document> _fetchPGRaw(String res, [Map<String, String> params]) =>
    _fetchResource(new Uri.https('www.perfectgame.org', res, params));

Future<Document> _postPGRaw(String res, Map<String, String> params) =>
    _postResource(new Uri.https('www.perfectgame.org', res, params));

Iterable<E> _stride<E>(Iterable<E> it, int stride) sync* {
  while (it.isNotEmpty) {
    yield it.first;
    it = it.skip(stride);
  }
}

Element _ancestorByTag(Element e, String tag) {
  while (e.localName != tag) e = e.parent;
  return e;
}

Future<Document> _fetchPlayerPage(String id) =>
    _fetchPGRaw('Players/Playerprofile.aspx', {"id": id});

Future<Player> dpgsFetchPlayer(String id) async =>
    new Player(id, await _fetchPlayerPage(id));

Future<Document> _performSearch(String q) =>
    _fetchPGRaw('Search.aspx', {'search': q});

Future<Document> _fetchTournamentsPage() =>
    _fetchPGRaw('Schedule/Default.aspx', {'Type': 'Tournaments'});

Future<Document> _postTournamentsPage(Map<String, String> params) {
  params["Type"] = "Tournaments";
  return _postPGRaw('Schedule/Default.aspx', params);
}

Iterable<Element> _getPlayerKeyedTableAnchors(Document d) =>
    d.querySelectorAll('tr a[href*="Playerprofile.aspx"]');

Iterable<Element> _getPlayerKeyedTableRows(Document d) =>
    _getPlayerKeyedTableAnchors(d).map((e) => _ancestorByTag(e, 'tr'));

Iterable<Element> _getEventBoxes(Document d) =>
    _stride(d.querySelectorAll("div.EventBox"), 2);

Future<Document> _fetchT50Page(String year) =>
    _fetchPGRaw('Rankings/Players/NationalRankings.aspx', {'gyear': year});

Future<Iterable<Tournament>> dpgsFetchTournamentsData(
    {Map<String, String> params = null}) async {
  final doc = await _fetchTournamentsPage();
  if (params != null) {
    dpgsScrapeTournamentPostParameters(doc, params);
  }
  return _getEventBoxes(doc).map(_getEventData);
}

Future<Iterable<Tournament>> dpgsPostTournamentsData(
        Map<String, String> params) async =>
    _getEventBoxes(await _postTournamentsPage(params)).map(_getEventData);

Future<Document> dpgsFetchTournamentTeamPage(Team t) =>
    _fetchPGRaw('Events/Tournaments/Teams/Default.aspx', {'team': t.id});

Iterable<Player> dpgsGetTournamentTeamRoster(Document doc) =>
    doc.querySelectorAll('tr a[id*="Roster"]').map((r) {
      final Element row = _ancestorByTag(r, 'tr');
      return new Player.unpopulated(
          pgid: _getID(r),
          name: r.text,
          pos: row.querySelector('*[id*="Position"]').text,
          year: new RegExp(r'20\d\d').stringMatch(row.text));
    });

Matchup _getMatchupForRows(DateTime day, Element game, Element teams) =>
    new Matchup(
        gameid: game.children[0].children[0].text,
        playtime: Dates.parsePGTime(day, game.children[0].children[1].text),
        maplink: game
            .querySelector('a[href*="maps.google.com"]')
            ?.attributes['href'],
        location: game.children[1].children[0].nodes
            .where((n) => !(n.attributes['id']?.contains('cleatrule') ?? false))
            .map((n) => n.text)
            .join()
            .split(new RegExp(r'\s+'))
            .join(' ')
            .trim(),
        teams: teams
            .querySelectorAll('a[href*="Tournaments/Teams"]')
            .map(_teamFromElement)
            .toList());

Iterable<Matchup> _getEventMatchups(Document d) sync* {
  final dateText = d.querySelector('*[id*="ScheduleDate"]')?.text;
  final DateTime day =
      dateText != null ? Dates.parsePGMedium(dateText) : new DateTime.now();
  final games =
      d.querySelector('div[id*="FullSchedule"]')?.querySelectorAll('div.row') ??
          [];
  final gameData = _stride(games, 2).iterator;
  final teams = _stride(games.skip(1), 2).iterator;
  while (gameData.moveNext() && teams.moveNext())
    yield _getMatchupForRows(day, gameData.current, teams.current);
}

Future<Iterable<String>> dpgsGetTournamentScheduleDates(String eid) async =>
    (await _fetchPGRaw(
            'Events/TournamentSchedule.aspx', {'event': eid, 'Date': '1/1/1'}))
        .querySelectorAll('a[id*="datepicker"]')
        .map(_getID);

Future<Iterable<Matchup>> dpgsGetTournamentScheduleMatchups(String eid) async =>
    (await Future.wait((await dpgsGetTournamentScheduleDates(eid)).map((d) =>
            _fetchPGRaw(
                'Events/TournamentSchedule.aspx', {'event': eid, 'Date': d}))))
        .map(_getEventMatchups)
        .expand((l) => l);

Iterable<DateTime> dpgsGetTournamentTeamPlaytimes(Document doc) => doc
    .querySelectorAll('div.repbg')
    .map((e) => e.querySelector('div.col-lg-3').children[1].text)
    .map(Dates.parsePGLong);

Iterable<Element> _getTournamentTeamAnchors(Document d) =>
    d.querySelectorAll('a[href*="Tournaments/Teams/Default.aspx"]');

String _getID(Element anchor) {
  final href = anchor.attributes['href'];
  return href.substring(href.lastIndexOf('=') + 1);
}

Future<Iterable<String>> _expandEventIds(Tournament t) async =>
    t.isGroup ? await _fetchEventsForEventGroup(t.id) : [t.id];

Future<Iterable<Team>> _fetchEventTeams(String eventid) async =>
    _getTournamentTeamAnchors(await _fetchPGRaw(
            'Events/TournamentTeams.aspx', {'event': eventid}))
        .map(_teamFromElement);

Team _teamFromElement(Element e) => new Team(_getID(e), e.text);

Future<List<Team>> _getEventsTeams(Iterable<String> eids) async =>
    (await Future.wait(eids.map(_fetchEventTeams))).expand((l) => l).toList();

Future<List<Team>> dpgsFetchTournamentTeams(Tournament t) async =>
    _getEventsTeams(await _expandEventIds(t));

Future<Iterable<String>> _fetchEventsForEventGroup(String gid) async =>
    (await _fetchPGRaw('Schedule/GroupedEvents.aspx', {'gid': gid}))
        .querySelectorAll('strong')
        .map((e) => _ancestorByTag(e, 'a'))
        .map(_getID);

Future<TournamentSchedule> dpgsFetchScheduleForTournament(Tournament t) async {
  final eids = (await _expandEventIds(t)).toList();
  final teams = await _getEventsTeams(eids);
  final tpages = await Future.wait(teams.map(dpgsFetchTournamentTeamPage));
  final rosters = new Map.fromIterables(teams.map((t) => t.id),
      tpages.map(dpgsGetTournamentTeamRoster).map((r) => r.toList()));
  final matchups =
      (await Future.wait(eids.map(dpgsGetTournamentScheduleMatchups)))
          .expand((l) => l)
          .toList();

  return new TournamentSchedule(
      tournament: t, rosters: rosters, matchups: matchups);
}

Future<List<TournamentSchedule>> dpgsFetchTournamentSchedules(
        {Map<String, String> params = null}) async =>
    Future.wait((await dpgsFetchTournamentsData(params: params))
        .map(dpgsFetchScheduleForTournament));

Future<List<TournamentSchedule>> dpgsPostTournamentSchedules(
        Map<String, String> params) async =>
    Future.wait((await dpgsPostTournamentsData(params))
        .map(dpgsFetchScheduleForTournament));

Future<Null> dpgsUpdateTournamentSchedules() async =>
    FirebaseAccess.putTournamentSchedules(await dpgsFetchTournamentSchedules());

Tuple2<String, String> _getIdName(Element e) => new Tuple2(_getID(e), e.text);

Future<Iterable<Player>> dpgsFetchTop50Players(String year) async =>
    _getPlayerKeyedTableRows(await _fetchT50Page(year)).map((r) {
      var idname = _getIdName(r.querySelector('a'));
      return new Player.unpopulated(
          pgid: idname.item1,
          name: idname.item2,
          pos: r.children[2].text,
          year: year);
    });

Future<Iterable<int>> dpgsFetchTop50Years() async =>
    (await _fetchT50Page("${new DateTime.now().year}"))
        .getElementById("ctl00_ContentPlaceHolder1_RadComboBox1_DropDown")
        .querySelectorAll("li")
        .map((e) => new RegExp(r"Class of ([\d]+)").firstMatch(e.text)[1])
        .map(int.parse);

Future<Iterable<Player>> dpgsSearchPlayers(String q) async =>
    _getPlayerKeyedTableRows(await _performSearch(q)).map((r) {
      var idname = _getIdName(r.children[0].children[0]);
      return new Player.unpopulated(
          pgid: idname.item1,
          name: idname.item2,
          pos: r.children[1].text,
          year: r.children[2].text);
    });

Tournament _getEventData(Element ebox) {
  final titleLocElem = ebox.querySelector("center");
  final anchor = _ancestorByTag(ebox, 'a');
  return new Tournament(
      id: _getID(anchor),
      title: titleLocElem.querySelector("strong").text,
      location: titleLocElem.nodes[2].text,
      isGroup: anchor.attributes['href'].contains('Grouped'),
      date:
          ebox.querySelector('div[style="font-weight:bold; float:left"]').text);
}

Future<Map<String, String>> dpgsGetTournamentFilterYears() async {
  final tournamentDocument = await _fetchTournamentsPage();
  return dpgsScrapeTournamentOptionTextValues(
      tournamentDocument, "#ContentPlaceHolder1_ddlYear");
}

// No need to actually scrape this.
Map<String, String> dpgsGetTournamentFilterMonths() => {
      "January": "ctl00\$ContentPlaceHolder1\$lbFirst",
      "February": "ctl00\$ContentPlaceHolder1\$lbSecond",
      "March": "ctl00\$ContentPlaceHolder1\$lbThird",
      "April": "ctl00\$ContentPlaceHolder1\$lbFourth",
      "May": "ctl00\$ContentPlaceHolder1\$lbFifth",
      "June": "ctl00\$ContentPlaceHolder1\$lbSixth",
      "July": "ctl00\$ContentPlaceHolder1\$lbSeventh",
      "August": "ctl00\$ContentPlaceHolder1\$lbEighth",
      "September": "ctl00\$ContentPlaceHolder1\$lbNinth",
      "October": "ctl00\$ContentPlaceHolder1\$lbTenth",
      "November": "ctl00\$ContentPlaceHolder1\$lbEleventh",
      "December": "ctl00\$ContentPlaceHolder1\$lbTwelveth"
    };

// No need to actually scrape this.
Map<String, String> dpgsGetDefaultTournamentPostParameters() => {
      "__ASYNCPOST": "false",
      "__EVENTARGUMENT": "",
      "__EVENTTARGET": "",
      "__EVENTVALIDATION": "",
      "__LASTFOCUS": "",
      "__VIEWSTATE": "",
      "__VIEWSTATEGENERATOR": "",
      "ctl00\$ContentPlaceHolder1\$ddlAgeDivision": "0",
      "ctl00\$ContentPlaceHolder1\$ddlState": "ZZ",
      "ctl00\$ContentPlaceHolder1\$ddlYear": "2018",
      "ctl00\$ContentPlaceHolder1\$rblTournaments": "1,2,3"
    };

// Can be used to scrape years, divisions, states, ect for filtering tournaments.
Map<String, String> dpgsScrapeTournamentOptionTextValues(
    Document doc, String id) {
  Map<String, String> output = new Map<String, String>();
  doc.querySelector(id)?.querySelectorAll("option")?.forEach((option) {
    final text = option.text ?? "";
    final value = option.attributes["value"] ?? "";

    if (text.isNotEmpty && value.isNotEmpty) {
      output[text] = value;
    }
  });

  return output;
}

// Unfortunately, we need to pass the postParameters by reference.
void dpgsScrapeTournamentPostParameters(
    Document doc, Map<String, String> postParameters) {
  // Do NOT get rid of these helper functions!
  // The attributes map can be null, so doing a simple attributes["value"] will cause a crash.
  // The putIfAbsent method returns null for empty strings for some reason.
  String getAttributeValue(String id) {
    final attributes = doc.getElementById(id)?.attributes;
    return (attributes != null) ? attributes["value"] ?? "" : "";
  }

  String getSelectedAttributeValue(String id, {String defaultValue = ""}) {
    final attributes = doc
        .getElementById(id)
        ?.querySelector("option[selected='selected']")
        ?.attributes;

    return (attributes != null)
        ? attributes["value"] ?? defaultValue
        : defaultValue;
  }

  postParameters["__EVENTARGUMENT"] = getAttributeValue("__EVENTARGUMENT");

  postParameters["__EVENTTARGET"] = getAttributeValue("__EVENTTARGET");

  postParameters["__EVENTVALIDATION"] = getAttributeValue("__EVENTVALIDATION");

  postParameters["__VIEWSTATE"] = getAttributeValue("__VIEWSTATE");

  postParameters["__VIEWSTATEGENERATOR"] =
      getAttributeValue("__VIEWSTATEGENERATOR");

  postParameters["ctl00\$ContentPlaceHolder1\$ddlYear"] =
      getSelectedAttributeValue("ContentPlaceHolder1_ddlYear",
          defaultValue: Dates.getCurrentYear());

  // ZZ decodes to all states.
  postParameters["ctl00\$ContentPlaceHolder1\$ddlState"] =
      getSelectedAttributeValue("ContentPlaceHolder1_ddlState",
          defaultValue: "ZZ");

  // 0 decodes to all age divisions.
  postParameters["ctl00\$ContentPlaceHolder1\$ddlAgeDivision"] =
      getSelectedAttributeValue("ContentPlaceHolder1_ddlAgeDivision",
          defaultValue: "0");
}
