import 'dart:async';

import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAccess {
  static Future<DatabaseReference> getDBRootRef() async {
    final fbase = FirebaseDatabase.instance;
    await fbase.setPersistenceEnabled(true);
    return fbase.reference();
  }

  static Future<DatabaseReference> getDBRef() async {
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    return (await getDBRootRef()).child('users/$uid');
  }

  static Future<DatabaseReference> getWatchlistDBRef() async =>
      (await getDBRef()).child('watchlist_v2');

  static Future<DatabaseReference> getNotesDBRef() async =>
      (await getDBRef()).child('player_notes');

  static Future<DatabaseReference> getTScheduleDBRef() async =>
      (await getDBRootRef()).child('tsched_v2');

  static Future<Null> pushPlayerNote(Player p, String note) async =>
      (await getNotesDBRef()).child('${p.pgid}').push().set(note);

  static Future<List<String>> getPlayerNotes(Player p) async {
    final dbref = (await getNotesDBRef()).child('${p.pgid}');
    return ((await dbref.orderByKey().once()).value ?? {})
        .values
        .cast<String>()
        .toList();
  }

  static Future<dynamic> getWatchlistEntries() async {
    final dbref = await getWatchlistDBRef();
    final entries = (await dbref.once()).value ?? {};
    return entries.keys.map((k) => {k: entries[k]}).toList();
  }

  static Future<List<Player>> getWatchlistPlayers() async =>
      (await getWatchlistEntries()).map<Player>(Player.fromWLEntry).toList();

  static Future<DatabaseReference> getWatchlistEntryRef(String pgid) async =>
      (await getWatchlistDBRef()).child(pgid);

  static Future<Null> addToWatchlist(Player p) async {
    p.watchlist = true;
    await (await getWatchlistEntryRef(p.pgid)).set(p.toWLEntry()[p.pgid]);
  }

  static Future<Null> removeFromWatchlist(Player p) async {
    p.watchlist = false;
    await (await getWatchlistEntryRef(p.pgid)).remove();
  }

  static Future<bool> isWatched(String pgid) async =>
      (await (await getWatchlistEntryRef(pgid)).once()).value != null;

  static Future<Null> toggleWatchlist(Player p) async =>
      await p.isWatched() ? removeFromWatchlist(p) : addToWatchlist(p);

  static Future<Null> putTournamentSchedules(
      Iterable<TournamentSchedule> ts) async {
    final dbref = await getTScheduleDBRef();
    await dbref.set(ts.map((t) => t.toMap()).toList());
  }

  static Future<Iterable<TournamentSchedule>> getTournamentSchedules() async {
    final dbref = await getTScheduleDBRef();
    return (await dbref.once())
        .value
        .map<TournamentSchedule>(TournamentSchedule.fromMap);
  }
}
