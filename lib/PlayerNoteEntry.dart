import 'package:flutter/material.dart';

import 'Player.dart';
import 'PlayerCache.dart';

class PlayerNoteEntry extends StatefulWidget {
  final Player player;
  PlayerNoteEntry(this.player);
  createState() => new PlayerNoteEntryState();
}

class PlayerNoteEntryState extends State<PlayerNoteEntry> {
  final cont = new TextEditingController();
  Widget build(BuildContext con) => new Scaffold(
      appBar:
          new AppBar(title: new Text("${widget.player.name} notes"), actions: [
        new IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              new PlayerCache().pushPlayerNote(widget.player, cont.text);
              Navigator.of(con).pop();
            }),
      ]),
      body: new Padding(
          padding: const EdgeInsets.all(20.0),
          child: new TextField(
            autofocus: true,
            controller: cont,
            decoration: new InputDecoration(icon: new Icon(Icons.note)),
            maxLines: 30,
          )));
}
