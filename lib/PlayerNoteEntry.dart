import 'package:flutter/material.dart';

import 'Player.dart';
import 'PlayerCache.dart';

class PlayerNoteEntry extends StatefulWidget {
  final Player player;
  PlayerNoteEntry(this.player);
  createState() => new PlayerNoteEntryState();
}

class PlayerNoteEntryState extends State<PlayerNoteEntry> {
  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("${widget.player.name} notes")),
      body: new TextField(
          decoration: new InputDecoration(icon: new Icon(Icons.note)),
          onSubmitted: (q) {
            new PlayerCache().pushPlayerNote(widget.player, q);
            Navigator.of(con).pop();
          }));
}
