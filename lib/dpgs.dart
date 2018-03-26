import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:range/range.dart';
import 'package:tuple/tuple.dart';

import 'Player.dart';
import 'Tournament.dart';

Future<Document> dpgsGetRaw(String res, [Map<String, String> params]) async {
  var client = new HttpClient();
  var uri = new Uri.https('www.perfectgame.org', res, params);
  var request = await client.getUrl(uri);
  var response = await request.close();
  var body = await response.transform(UTF8.decoder).join();
  var doc = parse(body);
  return doc;
}

Iterable<E> stride<E>(Iterable<E> it, int stride) sync* {
  while (it.isNotEmpty) {
    yield it.first;
    it = it.skip(stride);
  }
}

Element domUp(Element e, int levels) {
  range(levels).forEach((_) {
    e = e.parent;
  });
  return e;
}

Element ancestorByTag(Element e, String tag) {
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
    dpgsGetPlayerKeyedTableAnchors(d).map((e) => ancestorByTag(e, 'tr'));

Iterable<Element> dpgsGetEventBoxes(Document d) =>
    stride(d.querySelectorAll("div.EventBox"), 2);

Future<Document> dpgsGetTop50Raw(String year) =>
    dpgsGetRaw('Rankings/Players/NationalRankings.aspx', {'gyear': year});

Future<Iterable<Tournament>> dpgsGetTournamentsData() => dpgsGetTournaments()
    .then(dpgsGetEventBoxes)
    .then((e) => e.map(dpgsGetEventData));

Future<Iterable<String>> dpgsGetTournamentTeamRoster(String teamid) =>
    dpgsGetRaw('Events/Tournaments/Teams/Default.aspx', {'team': teamid}).then(
        (doc) => dpgsGetPlayerKeyedTableAnchors(doc)
            .map(dpgsGetIdName)
            .map((p) => p.item1));

Iterable<Element> dpgsGetTournamentTeamAnchors(Document d) =>
    d.querySelectorAll('a[href*="Tournaments/Teams/Default.aspx"]');

String getID(Element anchor) {
  final href = anchor.attributes['href'];
  return href.substring(href.lastIndexOf('=') + 1);
}

Future<Iterable<String>> dpgsGetTournamentTeams(String eventid) async =>
    dpgsGetRaw('Events/TournamentTeams.aspx', {'event': eventid})
        .then(dpgsGetTournamentTeamAnchors)
        .then((e) => e.map(getID));

Tuple2<String, String> dpgsGetIdName(Element e) => new Tuple2(getID(e), e.text);

Future<Iterable<Player>> dpgsGetTop50(String year) => dpgsGetTop50Raw(year)
    .then((d) => dpgsGetPlayerKeyedTableRows(d).map((r) {
          var idname = dpgsGetIdName(r.querySelector('a'));
          return new Player.unpopulated(
              idname.item1, idname.item2, r.children[2].text, year);
        }));

Future<Iterable<Player>> dpgsSearchPlayers(String q) =>
    dpgsGetSearch(q).then((d) => dpgsGetPlayerKeyedTableRows(d).map((r) {
          var idname = dpgsGetIdName(r.children[0].children[0]);
          return new Player.unpopulated(idname.item1, idname.item2,
              r.children[1].text, r.children[2].text);
        }));

Tournament dpgsGetEventData(Element ebox) {
  final date =
      ebox.querySelector('div[style="font-weight:bold; float:left"]').text;
  final titleLocElem = ebox.querySelector("center");
  final titleElem = titleLocElem.querySelector("strong");
  final title = titleElem.text;
  final location = titleLocElem.nodes[2].text;
  final id = getID(ancestorByTag(ebox, 'a'));
  return new Tournament(id, title, date, location);
}
