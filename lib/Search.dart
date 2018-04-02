import 'package:flutter/material.dart';

import 'dpgs.dart';
import 'Player.dart';
import 'PlayerListElementWidget.dart';

class PlayerSearchWidget extends StatefulWidget {
  const PlayerSearchWidget();
  State<StatefulWidget> createState() => new PlayerSearchWidgetState();
}

class PlayerSearchWidgetState extends State<PlayerSearchWidget> {
  List<Player> players = [];

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Player Search")),
      body: new Column(children: [
        new Padding(
            padding: const EdgeInsets.all(20.0),
            child: new TextField(
                decoration: const InputDecoration(icon: const Icon(Icons.search)),
                onSubmitted: (q) {
                  dpgsSearchPlayers(q).then((p) => setState(() {
                        players = new List.unmodifiable(p);
                      }));
                })),
        new Expanded(
            child: new ListView(
                children: new List.unmodifiable(
                    players.map((p) => new PlayerListElementWidget(p)))))
      ]));
}
