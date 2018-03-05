import 'dart:async';

import 'package:html/dom.dart';
import 'package:tuple/tuple.dart';

import 'dpgs.dart';

class Player {
  String pgid;
  String name;
  String year;
  String pos;
  String pos2;
  String age;
  String height;
  String weight;
  String bt;
  String hs;
  String town;
  String teamSummer;
  String teamFall;
  bool watchlist = false;
  bool populated;

  Player(Document html) {
    populate(html);
  }
  Future<Null> populateAsync() =>
      dpgsGetPlayerRaw(pgid).then((h) => populate(h));

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
    bt = html.querySelector("#ContentPlaceHolder1_Bio1_lblBatsThrows").text;
    hs = html.querySelector("#ContentPlaceHolder1_Bio1_lblHS").text;
    town = html.querySelector("#ContentPlaceHolder1_Bio1_lblHomeTown").text;
    teamSummer =
        html.querySelector("#ContentPlaceHolder1_Bio1_lblSummerTeam").text;
    teamFall = html.querySelector("#ContentPlaceHolder1_Bio1_lblFallTeam").text;
    populated = true;
  }

  Player.unpopulated(this.pgid, this.name, this.pos, this.year) {
    populated = false;
  }

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
    addIfNonNull(details, "Bats/Throws", bt);
    addIfNonNull(details, "High school", hs);
    addIfNonNull(details, "Hometown", town);
    addIfNonNull(details, "Summer team", teamSummer);
    addIfNonNull(details, "Fall team", teamFall);
    return details;
  }
}
