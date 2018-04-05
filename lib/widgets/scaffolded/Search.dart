import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search();
  State<StatefulWidget> createState() => new SearchState();
}

class SearchState extends State<Search> {
  List<Player> players = [];

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Player Search")),
      body: new Column(children: [
        new Padding(
            padding: const EdgeInsets.all(20.0),
            child: new TextField(
                decoration:
                    const InputDecoration(icon: const Icon(Icons.search)),
                onSubmitted: (q) {
                  dpgsSearchPlayers(q).then((p) => setState(() {
                        players = new List.unmodifiable(p);
                      }));
                })),
        new Expanded(
            child: new ListView(
                children: new List.unmodifiable(
                    players.map((p) => new PlayerListElement(p)))))
      ]));
}
