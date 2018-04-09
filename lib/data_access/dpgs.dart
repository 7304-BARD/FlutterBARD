import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/data_access/PlayerCache.dart';
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

Future<Document> _fetchPGRaw(String res, [Map<String, String> params]) =>
    _fetchResource(new Uri.https('www.perfectgame.org', res, params));

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

Iterable<Element> _getPlayerKeyedTableAnchors(Document d) =>
    d.querySelectorAll('tr a[href*="Playerprofile.aspx"]');

Iterable<Element> _getPlayerKeyedTableRows(Document d) =>
    _getPlayerKeyedTableAnchors(d).map((e) => _ancestorByTag(e, 'tr'));

Iterable<Element> _getEventBoxes(Document d) =>
    _stride(d.querySelectorAll("div.EventBox"), 2);

Future<Document> _fetchT50Page(String year) =>
    _fetchPGRaw('Rankings/Players/NationalRankings.aspx', {'gyear': year});

Future<Iterable<Tournament>> dpgsFetchTournamentsData() async =>
    _getEventBoxes(await _fetchTournamentsPage()).map(_getEventData);

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
        .map(_getIdName)
        .map((t) => new Team(t.item1, t.item2));

Future<List<Team>> dpgsFetchTournamentTeams(Tournament t) async =>
    (await Future.wait((await _expandEventIds(t)).map(_fetchEventTeams)))
        .expand((l) => l)
        .toList();

Future<Iterable<String>> _fetchEventsForEventGroup(String gid) async =>
    (await _fetchPGRaw('Schedule/GroupedEvents.aspx', {'gid': gid}))
        .querySelectorAll('strong')
        .map((e) => _ancestorByTag(e, 'a'))
        .map(_getID);

Future<TournamentSchedule> dpgsFetchScheduleForTournament(Tournament t) async {
  final teams = (await dpgsFetchTournamentTeams(t)).toList();
  final tpages = await Future.wait(teams.map(dpgsFetchTournamentTeamPage));
  final rosters =
      tpages.map(dpgsGetTournamentTeamRoster).map((r) => r.toList()).toList();
  final playtimes = tpages
      .map(dpgsGetTournamentTeamPlaytimes)
      .map((p) => p.toList())
      .toList();

  return new TournamentSchedule(
      tournament: t, teams: teams, rosters: rosters, playtimes: playtimes);
}

Future<List<TournamentSchedule>> dpgsFetchTournamentSchedules() async =>
    Future.wait(
        (await dpgsFetchTournamentsData()).map(dpgsFetchScheduleForTournament));

Future<Null> dpgsUpdateTournamentSchedules() async => new PlayerCache()
    .putTournamentSchedules(await dpgsFetchTournamentSchedules());

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
