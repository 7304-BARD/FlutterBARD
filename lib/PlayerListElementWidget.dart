import 'package:flutter/material.dart';

import 'Player.dart';

class PlayerListElementWidget extends StatefulWidget {
  final Player player;
  final Function onTap;

  PlayerListElementWidget(this.player, this.onTap);
  State<StatefulWidget> createState() => new PlayerListElementWidgetState();
}

class PlayerListElementWidgetState extends State<PlayerListElementWidget> {
  Widget build(BuildContext con) => new GestureDetector(
    onTap: widget.onTap,
    child: new Row(
      children: [
        new Expanded(
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Text(widget.player.name, style: new TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        new Text(widget.player.pos),
        new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Text(widget.player.year),
        ),
      ],
    )
  );
}
