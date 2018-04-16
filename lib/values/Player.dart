import 'dart:async';

import 'package:FlutterBARD/misc.dart';
import 'package:FlutterBARD/data_access/FirebaseAccess.dart';
import 'package:FlutterBARD/data_access/PlayerCache.dart';
import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

class Player implements Comparable<Player> {
  String pgid; // mandatory
  String name; // mandatory
  String year; // mandatory
  String pos; // mandatory
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
  String commitment;
  String commitmentLogoUrl;
  bool populated; // whether non-mandatory fields have been populated
  bool watchlist; // may be null, see Player.isWatched()
  int watchlistRank; // user-specified for watchlist ordering

  Player(this.pgid, Document html) {
    populate(html);
  }

  Future<Null> populateAsync() async {
    final pc = new PlayerCache();
    await pc.init();
    await pc.getPlayerMap(pgid).then((m) => populateFromMap(m));
  }

  static String _textOrById(Document html, String id, [String def]) =>
      html.getElementById(id)?.text ?? def;

  static String _attrOrNull(Element e, String attr) =>
      e == null ? null : e.attributes[attr];

  static String _srcOrSelect(Document html, String sel) =>
      _attrOrNull(html.querySelector(sel), 'src');

  populate(Document html) {
    name = _textOrById(html, "ContentPlaceHolder1_Bio1_lblName", "");
    year = _textOrById(html, "ContentPlaceHolder1_Bio1_lblGradYear", "");
    pos = _textOrById(html, "ContentPlaceHolder1_Bio1_lblPrimaryPosition", "");
    pos2 = _textOrById(html, "ContentPlaceHolder1_Bio1_lblOtherPositions");
    age = _textOrById(html, "ContentPlaceHolder1_Bio1_lblAgeNow");
    height = _textOrById(html, "ContentPlaceHolder1_Bio1_lblHeight");
    weight = _textOrById(html, "ContentPlaceHolder1_Bio1_lblWeight");
    bats_throws = _textOrById(html, "ContentPlaceHolder1_Bio1_lblBatsThrows");
    highschool = _textOrById(html, "ContentPlaceHolder1_Bio1_lblHS");
    town = _textOrById(html, "ContentPlaceHolder1_Bio1_lblHomeTown");
    teamSummer = _textOrById(html, "ContentPlaceHolder1_Bio1_lblSummerTeam");
    teamFall = _textOrById(html, "ContentPlaceHolder1_Bio1_lblFallTeam");

    photoUrl =
        _srcOrSelect(html, "#ContentPlaceHolder1_Bio1_imgMainPlayerImage");
    commitmentLogoUrl = _srcOrSelect(html, 'img[id*="4yearCollegeLogo"]');

    // We don't have access to player commitments on some players.
    commitment =
        _textOrById(html, "ContentPlaceHolder1_Bio1_hl4yearCommit", "");

    populated = true;
  }

  // just enough to display in a PlayerListElement, and to fetch more later
  Player.unpopulated(
      {@required this.pgid,
      @required this.name,
      @required this.pos,
      @required this.year}) {
    populated = false;
  }

  // Get an unpopulated player object from a watchlist entry.
  static Player fromWLEntry(dynamic wle) {
    final pgid = wle.keys.first;
    return new Player.unpopulated(
        pgid: pgid,
        name: wle[pgid]['name'],
        pos: wle[pgid]['pos'],
        year: wle[pgid]['year'])
      ..watchlistRank = wle[pgid]['watchlistRank'];
  }

  Map<String, Map<String, dynamic>> toWLEntry() => {
        pgid: {
          'name': name,
          'year': year,
          'pos': pos,
          'watchlistRank': watchlistRank
        }
      };

  populateFromMap(dynamic kv) {
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
    commitmentLogoUrl = kv['commitmentLogoUrl'];
    commitment = kv['commitment'];
    populated = true;
  }

  Player.fromMap(dynamic kv) {
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
        "commitment": commitment,
        "commitmentLogoUrl": commitmentLogoUrl,
      };

  static void addIfNonNull(
      List<Tuple2<String, String>> list, String key, String value) {
    if (value != null) list.add(new Tuple2(key, value));
  }

  // Used for displays. Keys should be user-friendly, not identifiers.
  List<Tuple2<String, String>> detailMap() {
    var details = new List<Tuple2<String, String>>();
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
    addIfNonNull(details, "Commitment", commitment);
    return details;
  }

  Future<bool> isWatched() async {
    if (watchlist == null) watchlist = await FirebaseAccess.isWatched(pgid);
    return watchlist;
  }

  // watchlistRank may be null, as for unwatched players.
  // We order such players last.
  int compareTo(Player p) => watchlistRank == null
      ? 1
      : p.watchlistRank == null ? -1 : watchlistRank.compareTo(p.watchlistRank);

  /// Updates [watchlistRank] to place this between [before] and [after].
  ///
  /// Returns true if the entire watchlist needs to be re-ranked.
  /// Normally, we avoid this, since each update must be written to FireBase.
  /// See [updateWatchlistRanks].
  Future<bool> updateWatchlistRank(Player before, Player after) async {
    int beforeRank = before?.watchlistRank ?? -0x20000000;
    int afterRank = after?.watchlistRank ?? 0x1fffffff;
    watchlistRank = average2(beforeRank, afterRank);
    if (watchlistRank == beforeRank || watchlistRank == afterRank) return true;

    await FirebaseAccess.updateWLRank(this);
    return false;
  }

  /// Updates [watchlistRank] for every watchlist player.
  ///
  /// We spread the players across the available namespace,
  /// to allow efficient insertions when a single player is moved.
  static Future<Null> updateWatchlistRanks(List<Player> watchlist) async {
    range(watchlist.length).forEach((int i) {
      watchlist[i].watchlistRank =
          (i + 1) * (0x1fffffff ~/ (watchlist.length + 2));
    });
    await Future.wait(watchlist.map(FirebaseAccess.updateWLRank));
  }
}
