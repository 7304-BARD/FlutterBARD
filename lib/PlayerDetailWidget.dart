import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'Player.dart';

class KVText extends StatelessWidget {
  final Tuple2<String, String> pair;

  KVText(this.pair);
  Widget build(BuildContext con) => new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        new Expanded(child: new Text(pair.item1)),
        new Align(child: new Text(pair.item2))
      ]));
}

class PlayerDetailWidget extends StatefulWidget {
  final Player player;

  PlayerDetailWidget(this.player);
  State<StatefulWidget> createState() => new PlayerDetailWidgetState();
}

class PlayerDetailWidgetState extends State<PlayerDetailWidget> {
  initState() {
    super.initState();
    if (!widget.player.populated) {
      widget.player.populateAsync().then((_) {
        setState(() {});
      });
    }
  }

  Widget build(BuildContext con) => new Align(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: new List.unmodifiable(
              widget.player.detailMap().map((p) => new KVText(p)))));
}
