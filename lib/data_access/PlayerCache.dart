import 'dart:async';

import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

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
    if (cpm == null || _isExpired(cpm)) {
      final Player player = await dpgsFetchPlayer(id);
      await db.put(player.toMap()..addAll({'expiry': _expiryTime().toString()}),
          player.pgid);
      return player;
    } else {
      return new Player.fromMap(cpm);
    }
  }

  static DateTime _expiryTime() =>
      new DateTime.now().add(const Duration(days: 7));

  static bool _isExpired(dynamic m) =>
      DateTime
          .parse(m['expiry'] ?? '1991-05-16 14:55:00')
          .compareTo(new DateTime.now()) <
      0;

  Future<List<Player>> getPlayersForIds(Iterable<String> ids) async {
    final List<Player> players = [];
    for (String id in ids) players.add(await getPlayerForId(id));
    return players;
  }
}
