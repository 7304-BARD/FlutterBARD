import 'dart:async';

import 'package:FlutterBARD/misc.dart';
import 'package:FlutterBARD/data_access/FirebaseAccess.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/scaffolded/Search.dart';
import 'package:flutter/material.dart';

class Watchlist extends StatefulWidget {
  const Watchlist();
  State<StatefulWidget> createState() => new WatchlistState();
}

class WatchlistState extends CheckedSetState<Watchlist> {
  List<Player> players = [];

  void refreshPlayers() async {
    players = await FirebaseAccess.getWatchlistPlayers();
    setState(() {});
  }

  void initState() {
    super.initState();
    refreshPlayers();
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: const Text("My Watchlist"), actions: [
        new IconButton(
          icon: const Icon(Icons.search),
          onPressed: tapNav((BuildContext con) => const Search(), con,
              () => refreshPlayers()),
        )
      ]),
      body: new ListView(
          children: range(players.length).map(_draggablePlayerLE).toList()
            ..add(_dragTarget(new Container(height: 30.0), players.length))));

  DragTarget<int> _draggablePlayerLE(int i) => _dragTarget(
      new LongPressDraggable<int>(
          data: i,
          child: new PlayerListElement(players[i], refreshPlayers),
          feedback: new Container()),
      i);

  Future<Null> _movePlayerBefore(int target, int moved) async {
    if (moved == target || moved == target - 1) return;

    final finalTarget = moved < target ? target - 1 : target;
    players.insert(finalTarget, players.removeAt(moved));
    if (await players[finalTarget].updateWatchlistRank(
        getOrNull(players, finalTarget - 1),
        getOrNull(players, finalTarget + 1)))
      await Player.updateWatchlistRanks(players);

    setState(() {});
  }

  DragTarget<int> _dragTarget(Widget child, int i) => new DragTarget<int>(
      onAccept: (int n) => _movePlayerBefore(i, n),
      builder: (BuildContext con, List candidates, List rejects) =>
          new Container(
              child: child,
              decoration: candidates.isEmpty
                  ? null
                  : new BoxDecoration(
                      border: new Border(
                          top: new BorderSide(
                              color: Theme.of(con).dividerColor,
                              width: 8.0)))));
}
