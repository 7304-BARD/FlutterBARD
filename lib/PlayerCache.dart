import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'dpgs.dart';
import 'Player.dart';
import 'TournamentSchedule.dart';

final _playerCacheSingleton = new PlayerCache._();

class PlayerCache {
  Database db;

  PlayerCache._();

  factory PlayerCache() {
    return _playerCacheSingleton;
  }

  Future<Null> init() async {
    if (db == null) {
      final docdir = await getApplicationDocumentsDirectory();
      final String dbFilename = docdir.path + "/players";
      db = await ioDatabaseFactory.openDatabase(dbFilename);
    }
  }

  Future<Map<String, dynamic>> getPlayerMap(String id) async =>
      (await getPlayerForId(id)).toMap();

  Future<Player> getPlayerForId(String id) async {
    final cpm = await db.get(id);
    if (cpm == null) {
      final Player player = await dpgsGetPlayer(id);
      await db.put(player.toMap(), player.pgid);
      return player;
    } else {
      return new Player.fromMap(cpm);
    }
  }

  Future<List<Player>> getPlayersForIds(Iterable<String> ids) async {
    final List<Player> players = [];
    for (String id in ids) players.add(await getPlayerForId(id));
    return players;
  }

  Future<DatabaseReference> getDBRootRef() async {
    final fbase = FirebaseDatabase.instance;
    await fbase.setPersistenceEnabled(true);
    return fbase.reference();
  }

  Future<DatabaseReference> getDBRef() async {
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    return (await getDBRootRef()).child('users/$uid');
  }

  Future<DatabaseReference> getWatchlistDBRef() async =>
      (await getDBRef()).child('watchlist_v2');

  Future<DatabaseReference> getNotesDBRef() async =>
      (await getDBRef()).child('player_notes');

  Future<DatabaseReference> getTScheduleDBRef() async =>
      (await getDBRootRef()).child('tsched');

  Future<Null> pushPlayerNote(Player p, String note) async =>
      (await getNotesDBRef()).child('${p.pgid}').push().set(note);

  Future<List<String>> getPlayerNotes(Player p) async {
    final dbref = (await getNotesDBRef()).child('${p.pgid}');
    final notes = ((await dbref.orderByKey().once()).value ?? {}).values;
    return notes.toList();
  }

  Future<List<Map<String, Map<String, dynamic>>>> getWatchlistEntries() async {
    final dbref = await getWatchlistDBRef();
    final entries = (await dbref.once()).value ?? {};
    return entries.keys.map((k) => {k: entries[k]}).toList();
  }

  Future<List<Player>> getWatchlistPlayers() async =>
      (await getWatchlistEntries()).map(Player.fromWLEntry).toList();

  Future<DatabaseReference> getWatchlistEntryRef(String pgid) async =>
      (await getWatchlistDBRef()).child(pgid);

  Future<Null> addToWatchlist(Player p) async {
    p.watchlist = true;
    await (await getWatchlistEntryRef(p.pgid)).set(p.toWLEntry());
  }

  Future<Null> removeFromWatchlist(Player p) async {
    p.watchlist = false;
    await (await getWatchlistEntryRef(p.pgid)).remove();
  }

  Future<bool> isWatched(String pgid) async =>
      (await (await getWatchlistEntryRef(pgid)).once()).value != null;

  Future<Null> toggleWatchlist(Player p) async =>
      await p.isWatched() ? removeFromWatchlist(p) : addToWatchlist(p);

  Future<Null> putTournamentSchedules(Iterable<TournamentSchedule> ts) async {
    final dbref = await getTScheduleDBRef();
    await dbref.set(ts.map((t) => t.toMap()).toList());
  }

  Future<Iterable<TournamentSchedule>> getTournamentSchedules() async {
    final dbref = await getTScheduleDBRef();
    return (await dbref.once()).value.map(TournamentSchedule.fromMap);
  }
}
