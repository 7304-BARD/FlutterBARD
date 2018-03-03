import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:tuple/tuple.dart';

import 'Player.dart';

Future<Document> dpgsGetRaw(String res, [Map<String, String> params]) async {
  var client = new HttpClient();
  var uri = new Uri.https('www.perfectgame.org', res, params);
  var request = await client.getUrl(uri);
  var response = await request.close();
  var body = await response.transform(UTF8.decoder).join();
  var doc = parse(body);
  return doc;
}

Future<Document> dpgsGetPlayerRaw(String id) => dpgsGetRaw('Players/Playerprofile.aspx', {"id": id});
Future<Player> dpgsGetPlayer(String id) async => new Player(await dpgsGetPlayerRaw(id));
Future<Document> dpgsGetSearch(String q) => dpgsGetRaw('Search.aspx', {'search': q});
Future<Document> dpgsGetTournaments() => dpgsGetRaw('Schedule/Default.aspx', {'Type': 'Tournaments'});
Iterable<Element> dpgsGetPlayerKeyedTableRows(Document d) => d.querySelectorAll('tr a[href*="Playerprofile.aspx"]').map((e) => e.parent.parent.parent.parent);
Iterable<Element> dpgsGetEventBoxes(Document d) => d.querySelectorAll("div.EventBox");
Future<Document> dpgsGetTop50Raw(String year) => dpgsGetRaw('Rankings/Players/NationalRankings.aspx', {'gyear': year});

Tuple2<String, String> dpgsGetIdName(Element e) {
  String href = e.attributes["href"];
  return new Tuple2(href.substring(href.lastIndexOf('=') + 1), e.text);
}

Future<List<Player>> dpgsGetTop50(String year) async {
  var list = new List();
  for (var r in dpgsGetPlayerKeyedTableRows(await dpgsGetTop50Raw(year))) {
    var idname = dpgsGetIdName(r.querySelector('a'));
    list.add(new Player.unpopulated(idname.item1, idname.item2, r.children[2].text, year));
  }
  return list;
}

Tuple3<String, String, String> dpgsGetEventData(Element ebox) {
  var date = ebox.querySelector('div[style="font-weight:bold; float:left"]').text;
  var titleLocElem = ebox.querySelector("center");
  var titleElem = titleLocElem.querySelector("strong");
  var title = titleElem.text;
  var location = titleLocElem; // .textNodes().get(0).text()
  return new Tuple3(title, date, "");
}

Future<List<Tuple3<String, String, String>>> dpgsGetTournamentsData() async {
  var list = new List();
  for (var e in dpgsGetEventBoxes(await dpgsGetTournaments())) {
    list.add(dpgsGetEventData(e));
  }
  return list;
}

Future<List<Player>> dpgsSearchPlayers(String q) async {
  var list = new List();
  for (var r in dpgsGetPlayerKeyedTableRows(await dpgsGetSearch(q))) {
    var idname = dpgsGetIdName(r.children[0].children[0]);
    list.add(new Player.unpopulated(idname.item1, idname.item2, r.children[1].text, r.children[2].text));
  }
  return list;
}
