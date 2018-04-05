import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:FlutterBARD/data_access/PlayerCache.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:range/range.dart';
import 'package:tuple/tuple.dart';

Future<Document> _getResource(Uri uri) async {
  try {
    final request = await new HttpClient().getUrl(uri);
    final response = await request.close();
    final body = await response.transform(const Utf8Codec().decoder).join();
    return parse(body);
  } catch (e) {
    return _getResource(uri);
  }
}

Future<Document> dpgsGetRaw(String res, [Map<String, String> params]) =>
    _getResource(new Uri.https('www.perfectgame.org', res, params));

Iterable<E> _stride<E>(Iterable<E> it, int stride) sync* {
  while (it.isNotEmpty) {
    yield it.first;
    it = it.skip(stride);
  }
}

Element _domUp(Element e, int levels) {
  range(levels).forEach((_) {
    e = e.parent;
  });
  return e;
}

Element _ancestorByTag(Element e, String tag) {
  while (e.localName != tag) e = e.parent;
  return e;
}

Future<Document> dpgsGetPlayerRaw(String id) =>
    dpgsGetRaw('Players/Playerprofile.aspx', {"id": id});

Future<Player> dpgsGetPlayer(String id) =>
    dpgsGetPlayerRaw(id).then((d) => new Player(id, d));

Future<Document> dpgsGetSearch(String q) =>
    dpgsGetRaw('Search.aspx', {'search': q});

Future<Document> dpgsGetTournaments() =>
    dpgsGetRaw('Schedule/Default.aspx', {'Type': 'Tournaments'});

Iterable<Element> dpgsGetPlayerKeyedTableAnchors(Document d) =>
    d.querySelectorAll('tr a[href*="Playerprofile.aspx"]');

Iterable<Element> dpgsGetPlayerKeyedTableRows(Document d) =>
    dpgsGetPlayerKeyedTableAnchors(d).map((e) => _ancestorByTag(e, 'tr'));

Iterable<Element> dpgsGetEventBoxes(Document d) =>
    _stride(d.querySelectorAll("div.EventBox"), 2);

Future<Document> dpgsGetTop50Raw(String year) =>
    dpgsGetRaw('Rankings/Players/NationalRankings.aspx', {'gyear': year});

Future<Iterable<Tournament>> dpgsGetTournamentsData() => dpgsGetTournaments()
    .then(dpgsGetEventBoxes)
    .then((e) => e.map(dpgsGetEventData));

Future<Document> dpgsGetTournamentTeamPage(Team t) =>
    dpgsGetRaw('Events/Tournaments/Teams/Default.aspx', {'team': t.id});

Iterable<Player> dpgsGetTournamentTeamRoster(Document doc) =>
    doc.querySelectorAll('tr a[id*="Roster"]').map((r) {
      final Element row = _ancestorByTag(r, 'tr');
      return new Player.unpopulated(
          pgid: _getID(r),
          name: r.text,
          pos: row.querySelector('*[id*="Position"]').text,
          year: new RegExp(r'20\d\d').stringMatch(row.text));
    });

DateTime _parsePGDateTime(String s) {
  final match = new RegExp(
          r'^\s*(\d?\d)/(\d?\d)/(\d\d\d\d)\s*(\d?\d):(\d\d)\s*(A|P)M\s*$')
      .firstMatch(s);
  final dt = new DateTime(
      int.parse(match[3]),
      int.parse(match[1]),
      int.parse(match[2]),
      (int.parse(match[4]) % 12) + (match[6] == 'A' ? 0 : 12),
      int.parse(match[5]));
  return dt;
}

Iterable<DateTime> dpgsGetTournamentTeamPlaytimes(Document doc) => doc
    .querySelectorAll('div.repbg')
    .map((e) => e.querySelector('div.col-lg-3').children[1].text)
    .map(_parsePGDateTime);

Iterable<Element> dpgsGetTournamentTeamAnchors(Document d) =>
    d.querySelectorAll('a[href*="Tournaments/Teams/Default.aspx"]');

String _getID(Element anchor) {
  final href = anchor.attributes['href'];
  return href.substring(href.lastIndexOf('=') + 1);
}

Future<Iterable<String>> _expandEventIds(Tournament t) async =>
    t.isGroup ? await dpgsGetEventsForEventGroup(t.id) : [t.id];

Future<Iterable<Team>> dpgsGetEventTeams(String eventid) async =>
    dpgsGetRaw('Events/TournamentTeams.aspx', {'event': eventid})
        .then(dpgsGetTournamentTeamAnchors)
        .then((e) => e.map(_getIdName).map((t) => new Team(t.item1, t.item2)));

Future<Iterable<Team>> dpgsGetTournamentTeams(Tournament t) async {
  final teams = <Team>[];
  for (final e in await _expandEventIds(t))
    teams.addAll(await dpgsGetEventTeams(e));
  return teams;
}

Future<Iterable<String>> dpgsGetEventsForEventGroup(String gid) async =>
    (await dpgsGetRaw('Schedule/GroupedEvents.aspx', {'gid': gid}))
        .querySelectorAll('strong')
        .map((e) => _ancestorByTag(e, 'a'))
        .map(_getID);

Future<TournamentSchedule> dpgsGetScheduleForTournament(Tournament t) async {
  final teams = (await dpgsGetTournamentTeams(t)).toList();
  final tpages = await Future.wait(teams.map(dpgsGetTournamentTeamPage));
  final rosters =
      tpages.map(dpgsGetTournamentTeamRoster).map((r) => r.toList()).toList();
  final playtimes = tpages
      .map(dpgsGetTournamentTeamPlaytimes)
      .map((p) => p.toList())
      .toList();

  return new TournamentSchedule(
      tournament: t, teams: teams, rosters: rosters, playtimes: playtimes);
}

Future<List<TournamentSchedule>> dpgsGetTournamentSchedules() async => Future
    .wait((await dpgsGetTournamentsData()).map(dpgsGetScheduleForTournament));

Future<Null> dpgsUpdateTournamentSchedules() async => new PlayerCache()
    .putTournamentSchedules(await dpgsGetTournamentSchedules());

Tuple2<String, String> _getIdName(Element e) => new Tuple2(_getID(e), e.text);

Future<Iterable<Player>> dpgsGetTop50(String year) =>
    dpgsGetTop50Raw(year).then((d) => dpgsGetPlayerKeyedTableRows(d).map((r) {
          var idname = _getIdName(r.querySelector('a'));
          return new Player.unpopulated(
              pgid: idname.item1,
              name: idname.item2,
              pos: r.children[2].text,
              year: year);
        }));

Future<Iterable<int>> dpgsGetTop50Years() {
  int currentYear = new DateTime.now().year;
  return dpgsGetTop50Raw("$currentYear").then((document) {
    final id = "ctl00_ContentPlaceHolder1_RadComboBox1_DropDown";
    final rootNode = document.getElementById(id);
    final listItems = rootNode.querySelectorAll("li");
    List<int> years = [];
    listItems.forEach((item) {
      final classOf = item.text;
      final match = new RegExp(r"Class of ([\d]+)").firstMatch(classOf);
      int year = int.parse(match.group(1));
      years.add(year);
    });
    return years;
  });
}

Future<Iterable<Player>> dpgsSearchPlayers(String q) =>
    dpgsGetSearch(q).then((d) => dpgsGetPlayerKeyedTableRows(d).map((r) {
          var idname = _getIdName(r.children[0].children[0]);
          return new Player.unpopulated(
              pgid: idname.item1,
              name: idname.item2,
              pos: r.children[1].text,
              year: r.children[2].text);
        }));

Tournament dpgsGetEventData(Element ebox) {
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
