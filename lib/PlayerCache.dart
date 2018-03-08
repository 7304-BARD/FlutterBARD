import 'dart:async';

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

  Future<Iterable<Player>> getPlayersForIds(Iterable<String> ids) async {
    final List<Player> players = [];
    for (String id in ids) players.add(await getPlayerForId(id));
    return players;
  }

  Future<Iterable<Player>> getWatchlistPlayers() async =>
      getPlayersForIds(await db.get("watchlist") ?? []);

  Future<Null> addToWatchlist(Player p) async {
    p.watchlist = true;
    final wl = await db.get("watchlist") ?? [];
    if (!wl.contains(p.pgid)) {
      wl.add(p.pgid);
      await db.put(p.toMap(), p.pgid);
      await db.put(wl, "watchlist");
    }
  }

  Future<Null> removeFromWatchlist(Player p) async {
    p.watchlist = false;
    final wl = await db.get("watchlist") ?? [];
    if (wl.remove(p.pgid)) {
      await db.put(wl, "watchlist");
      await db.put(p.toMap(), p.pgid);
    }
  }
}
