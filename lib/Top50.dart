import 'package:flutter/material.dart';

import 'dpgs.dart';
import 'Player.dart';
import 'PlayerListElementWidget.dart';

class Top50 extends StatefulWidget {
  State<StatefulWidget> createState() => new Top50State();
  final String year;
  Top50(this.year);
}

class Top50State extends State<Top50> {
  List<Player> players = [];

  initState() {
    super.initState();
    dpgsGetTop50(widget.year).then((p) {
      setState(() {
        players = new List.unmodifiable(p);
      });
    });
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Top Players of ${widget.year}")),
      body: new ListView(
          children: new List.unmodifiable(
              players.map((p) => new PlayerListElementWidget(p)))));
}
