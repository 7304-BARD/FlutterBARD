import 'package:FlutterBARD/data_access/FirebaseAccess.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:flutter/material.dart';

class PlayerNoteEntry extends StatefulWidget {
  final Player player;
  PlayerNoteEntry(this.player);
  createState() => new PlayerNoteEntryState();
}

class PlayerNoteEntryState extends CheckedSetState<PlayerNoteEntry> {
  final cont = new TextEditingController();
  Widget build(BuildContext con) => new Scaffold(
      appBar:
          new AppBar(title: new Text("${widget.player.name} notes"), actions: [
        new IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              FirebaseAccess.pushPlayerNote(widget.player, cont.text);
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
