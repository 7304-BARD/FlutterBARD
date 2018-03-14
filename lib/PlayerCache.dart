import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'dpgs.dart';
import 'Player.dart';

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

  Future<DatabaseReference> getWatchlistDBRef() async {
    final fbase = FirebaseDatabase.instance;
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    await fbase.setPersistenceEnabled(true);
    return fbase.reference().child('users/$uid/watchlist');
  }

  Future<List<String>> getWatchlistIds() async {
    final dbref = await getWatchlistDBRef();
    final snapshot = await dbref.once();
    final ids = snapshot.value ?? [];
    return new List.unmodifiable(ids.where((t) => t != null));
  }

  Future<Null> setWatchlistIds(List<String> watchlist) async {
    final dbref = await getWatchlistDBRef();
    await dbref.set(watchlist);
  }

  Future<List<Player>> getWatchlistPlayers() async =>
      getPlayersForIds(await getWatchlistIds());

  Future<Null> addToWatchlist(Player p) async {
    p.watchlist = true;
    var wl = await getWatchlistIds();
    if (!wl.contains(p.pgid)) {
      wl = new List.from(wl);
      wl.add(p.pgid);
      debugPrint("$wl");
      await setWatchlistIds(wl);
      await db.put(p.toMap(), p.pgid);
    }
  }

  Future<Null> removeFromWatchlist(Player p) async {
    p.watchlist = false;
    final wl = new List.from(await getWatchlistIds());
    if (wl.remove(p.pgid)) {
      await setWatchlistIds(wl);
      await db.put(p.toMap(), p.pgid);
    }
  }
}
