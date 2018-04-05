import 'dart:async';

import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import 'PlayerCache.dart';

class Player {
  String pgid;
  String name;
  String year;
  String pos;
  String pos2;
  String age;
  String height;
  String weight;
  String bats_throws;
  String highschool;
  String town;
  String teamSummer;
  String teamFall;
  String photoUrl;
  bool populated;
  bool watchlist;

  Player(this.pgid, Document html) {
    populate(html);
  }
  Future<Null> populateAsync(PlayerCache pc) async {
    await pc.init();
    await pc.getPlayerMap(pgid).then((m) => populateFromMap(m));
  }

  populate(Document html) {
    name = html.querySelector("#ContentPlaceHolder1_Bio1_lblName").text;
    year = html.querySelector("#ContentPlaceHolder1_Bio1_lblGradYear").text;
    pos =
        html.querySelector("#ContentPlaceHolder1_Bio1_lblPrimaryPosition").text;
    pos2 =
        html.querySelector("#ContentPlaceHolder1_Bio1_lblOtherPositions").text;
    age = html.querySelector("#ContentPlaceHolder1_Bio1_lblAgeNow").text;
    height = html.querySelector("#ContentPlaceHolder1_Bio1_lblHeight").text;
    weight = html.querySelector("#ContentPlaceHolder1_Bio1_lblWeight").text;
    bats_throws =
        html.querySelector("#ContentPlaceHolder1_Bio1_lblBatsThrows").text;
    highschool = html.querySelector("#ContentPlaceHolder1_Bio1_lblHS").text;
    town = html.querySelector("#ContentPlaceHolder1_Bio1_lblHomeTown").text;
    teamSummer =
        html.querySelector("#ContentPlaceHolder1_Bio1_lblSummerTeam").text;
    teamFall = html.querySelector("#ContentPlaceHolder1_Bio1_lblFallTeam").text;
    photoUrl = html
        .querySelector("#ContentPlaceHolder1_Bio1_imgMainPlayerImage")
        .attributes['src'];
    populated = true;
  }

  Player.unpopulated(
      {@required this.pgid,
      @required this.name,
      @required this.pos,
      @required this.year}) {
    populated = false;
  }

  static fromWLEntry(Map<String, Map<String, dynamic>> wle) {
    final pgid = wle.keys.first;
    return new Player.unpopulated(
        pgid: pgid,
        name: wle[pgid]['name'],
        pos: wle[pgid]['pos'],
        year: wle[pgid]['year']);
  }

  Map<String, Map<String, dynamic>> toWLEntry() => {
        pgid: {'name': name, 'year': year, 'pos': pos}
      };

  populateFromMap(Map<String, dynamic> kv) {
    pgid = kv['pgid'];
    name = kv['name'];
    year = kv['year'];
    pos = kv['pos'];
    pos2 = kv['pos2'];
    age = kv['age'];
    height = kv['height'];
    weight = kv['weight'];
    bats_throws = kv['bt'];
    highschool = kv['hs'];
    town = kv['town'];
    teamSummer = kv['teamSummer'];
    teamFall = kv['teamFall'];
    photoUrl = kv['photoUrl'];
    populated = true;
  }

  Player.fromMap(Map<String, dynamic> kv) {
    populateFromMap(kv);
  }

  Map<String, dynamic> toMap() => {
        "pgid": pgid,
        "name": name,
        "year": year,
        "pos": pos,
        "pos2": pos2,
        "age": age,
        "height": height,
        "weight": weight,
        "bt": bats_throws,
        "hs": highschool,
        "town": town,
        "teamSummer": teamSummer,
        "teamFall": teamFall,
        "photoUrl": photoUrl,
      };

  void addIfNonNull(
      List<Tuple2<String, String>> list, String key, String value) {
    if (value != null) list.add(new Tuple2(key, value));
  }

  List<Tuple2<String, String>> detailMap() {
    var details = new List<Tuple2<String, String>>();
    addIfNonNull(details, "ID", pgid);
    addIfNonNull(details, "Name", name);
    addIfNonNull(details, "Grad year", year);
    addIfNonNull(details, "Primary position", pos);
    addIfNonNull(details, "Other positions", pos2);
    addIfNonNull(details, "Age", age);
    addIfNonNull(details, "Height", height);
    addIfNonNull(details, "Weight", weight);
    addIfNonNull(details, "Bats/Throws", bats_throws);
    addIfNonNull(details, "High school", highschool);
    addIfNonNull(details, "Hometown", town);
    addIfNonNull(details, "Summer team", teamSummer);
    addIfNonNull(details, "Fall team", teamFall);
    return details;
  }

  Future<bool> isWatched() async {
    if (watchlist == null) watchlist = await new PlayerCache().isWatched(pgid);
    return watchlist;
  }
}
