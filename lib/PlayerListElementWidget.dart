import 'package:flutter/material.dart';

import 'Player.dart';
import 'PlayerDetailWidget.dart';
import 'TapNav.dart';

void nop() {}

class PlayerListElementWidget extends StatefulWidget {
  final Player player;
  final Function onDismissed;

  PlayerListElementWidget(this.player, [this.onDismissed = nop]);
  State<StatefulWidget> createState() => new PlayerListElementWidgetState();
}

class PlayerListElementWidgetState extends State<PlayerListElementWidget> {
  Widget build(BuildContext con) => new TapNav<Null>(
      builder: (BuildContext con) => new PlayerDetailWidget(widget.player),
      onDismissed: (widget.onDismissed),
      child: new Row(
        children: [
          new Expanded(
            child: new Padding(
              padding: new EdgeInsets.all(8.0),
              child: new Text(widget.player.name,
                  style: new TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          new Text(widget.player.pos),
          new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Text(widget.player.year),
          ),
        ],
      ));
}
