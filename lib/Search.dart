import 'package:flutter/material.dart';

import 'dpgs.dart';
import 'Player.dart';
import 'PlayerDetailWidget.dart';
import 'PlayerListElementWidget.dart';

class PlayerSearchWidget extends StatefulWidget {
  State<StatefulWidget> createState() => new PlayerSearchWidgetState();
}

class PlayerSearchWidgetState extends State<PlayerSearchWidget> {
  List<Player> players = [];

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Player Search")),
      body: new Column(children: [
        new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new TextField(
                decoration: new InputDecoration(icon: new Icon(Icons.search)),
                onSubmitted: (q) {
                  dpgsSearchPlayers(q).then((p) => setState(() {
                        players = new List.unmodifiable(p);
                      }));
                })),
        new Expanded(
            child: new ListView(
                children: new List.unmodifiable(
                    players.map((p) => new PlayerListElementWidget(p, () {
                          Navigator.of(con).push(new MaterialPageRoute<Null>(
                              builder: (BuildContext con) =>
                                  new PlayerDetailWidget(p)));
                        })))))
      ]));
}
