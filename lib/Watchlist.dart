import 'package:flutter/material.dart';

import 'Player.dart';
import 'PlayerCache.dart';
import 'PlayerDetailWidget.dart';
import 'PlayerListElementWidget.dart';
import 'Search.dart';

class Watchlist extends StatefulWidget {
  State<StatefulWidget> createState() => new WatchlistState();
}

class WatchlistState extends State<Watchlist> {
  PlayerCache pcache = new PlayerCache();
  List<Player> players = [];

  void initState() {
    super.initState();
    pcache.init().then((_) {
      pcache.getWatchlistPlayers().then((i) => setState(() {
            players = new List.unmodifiable(i);
          }));
    });
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("My Watchlist")),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.search),
          onPressed: () {
            Navigator
                .of(con)
                .push(new MaterialPageRoute<Null>(
                    builder: (BuildContext con) => new PlayerSearchWidget()))
                .then((_) => setState(() {initState(); }));
          }),
      body: new ListView(
          children: new List.unmodifiable(
              players.map((p) => new PlayerListElementWidget(p, () {
                    Navigator.of(con).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext con) =>
                            new PlayerDetailWidget(p)));
                  })))));
}
