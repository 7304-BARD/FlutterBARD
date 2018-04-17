import 'dart:async';

import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAccess {
  // reference to the Firebase root
  static Future<DatabaseReference> _getDBRootRef() async {
    final fbase = FirebaseDatabase.instance;
    await fbase.setPersistenceEnabled(true);
    return fbase.reference();
  }

  // reference to the per-user keys
  static Future<DatabaseReference> _getDBRef() async {
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    return (await _getDBRootRef()).child('users/$uid');
  }

  // The watchlist_v2 key contains a map with Player.pgid as key.
  // The Player class is responsible for the map values.
  static Future<DatabaseReference> _getWatchlistDBRef() async =>
      (await _getDBRef()).child('watchlist_v2');

  // The player_notes key contains a map with auto-generated keys.
  // The values are user-supplied strings.
  static Future<DatabaseReference> _getNotesDBRef() async =>
      (await _getDBRef()).child('player_notes');

  // The tsched_v2 key contains a list of JSON-ified TournamentSchedule objects.
  // The TournamentSchedule class is responsible for the representation.
  static Future<DatabaseReference> _getTScheduleDBRef() async =>
      (await _getDBRootRef()).child('tsched_v2');

  static Future<Null> pushPlayerNote(Player p, String note) async =>
      await (await _getNotesDBRef()).child('${p.pgid}').push().set(note);

  static Future<List<String>> getPlayerNotes(Player p) async {
    final dbref = (await _getNotesDBRef()).child('${p.pgid}');
    return ((await dbref.orderByKey().once()).value ?? {})
        .values
        .cast<String>()
        .toList();
  }

  static Future<Null> updateWLRank(Player p) async {
    await (await _getWatchlistEntryRef(p.pgid))
        .child('watchlistRank')
        .set(p.watchlistRank);
  }

  static Future<dynamic> _getWatchlistEntries() async {
    final dbref = await _getWatchlistDBRef();
    final entries = (await dbref.once()).value ?? {};
    return entries.keys.map((k) => {k: entries[k]}).toList();
  }

  static Future<List<Player>> getWatchlistPlayers() async =>
      (await _getWatchlistEntries()).map<Player>(Player.fromWLEntry).toList()
        ..sort();

  static Future<DatabaseReference> _getWatchlistEntryRef(String pgid) async =>
      (await _getWatchlistDBRef()).child(pgid);

  static Future<Null> addToWatchlist(Player p) async {
    final watchlistPlayers = await getWatchlistPlayers();

    p.watchlist = true;
    await (await _getWatchlistEntryRef(p.pgid)).set(p.toWLEntry()[p.pgid]);

    // Newly-added players to the watchlist are inserted at the beginning.
    if (await p.updateWatchlistRank(null, watchlistPlayers.first))
      await Player.updateWatchlistRanks(watchlistPlayers..insert(0, p));
  }

  static Future<Null> removeFromWatchlist(Player p) async {
    p.watchlist = false;
    await (await _getWatchlistEntryRef(p.pgid)).remove();
  }

  static Future<bool> isWatched(String pgid) async =>
      (await (await _getWatchlistEntryRef(pgid)).once()).value != null;

  static Future<Null> toggleWatchlist(Player p) async =>
      await p.isWatched() ? removeFromWatchlist(p) : addToWatchlist(p);

  static Future<Null> putTournamentSchedules(
      Iterable<TournamentSchedule> ts) async {
    final dbref = await _getTScheduleDBRef();
    await dbref.set(ts.map((t) => t.toMap()).toList());
  }

  static Future<Iterable<TournamentSchedule>> getTournamentSchedules() async {
    final dbref = await _getTScheduleDBRef();
    return (await dbref.once())
        .value
        .map<TournamentSchedule>(TournamentSchedule.fromMap);
  }
}
