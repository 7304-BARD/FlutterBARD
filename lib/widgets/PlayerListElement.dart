import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/scaffolded/PlayerDetail.dart';
import 'package:flutter/material.dart';

void nop() {}

class PlayerListElement extends StatefulWidget {
  final Player player;
  final Function onDismissed;

  const PlayerListElement(this.player, [this.onDismissed = nop]);
  State<StatefulWidget> createState() => new PlayerListElementState();
}

class PlayerListElementState extends State<PlayerListElement> {
  Widget build(BuildContext con) => new TapNav(
      builder: (BuildContext con) => new PlayerDetail(widget.player),
      onDismissed: (widget.onDismissed),
      child: new Row(
        children: [
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(widget.player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          new Text(widget.player.pos),
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(widget.player.year),
          ),
        ],
      ));
}
