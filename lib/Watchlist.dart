import 'package:flutter/material.dart';

import 'package:FlutterBARD/Player.dart';
import 'package:FlutterBARD/PlayerCache.dart';
import 'package:FlutterBARD/PlayerListElementWidget.dart';
import 'package:FlutterBARD/Search.dart';
import 'package:FlutterBARD/TapNav.dart';

class Watchlist extends StatefulWidget {
  const Watchlist();
  State<StatefulWidget> createState() => new WatchlistState();
}

class WatchlistState extends State<Watchlist> {
  PlayerCache pcache = new PlayerCache();
  List<Player> players = [];

  void refreshPlayers() async {
    await pcache.init();
    players = await pcache.getWatchlistPlayers();
    setState(() {});
  }

  void initState() {
    super.initState();
    refreshPlayers();
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: const Text("My Watchlist")),
      floatingActionButton: new FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: tapNav((BuildContext con) => const PlayerSearchWidget(), con,
            () => refreshPlayers()),
      ),
      body: new ListView(
          children: new List.unmodifiable(players
              .map((p) => new PlayerListElementWidget(p, refreshPlayers)))));
}
