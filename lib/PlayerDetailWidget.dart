import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'Player.dart';
import 'PlayerCache.dart';

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
  PlayerCache pcache = new PlayerCache();

  initState() {
    super.initState();
    if (!widget.player.populated) {
      widget.player.populateAsync(pcache).then((_) {
        setState(() {});
      });
    }
  }

  Widget build(BuildContext con) => new Align(
      child: new Scaffold(
          appBar: new AppBar(title: new Text(widget.player.name), actions: [
            new IconButton(
                icon: new Icon(
                    widget.player.watchlist ? Icons.star : Icons.star_border),
                onPressed: () {
                  (widget.player.watchlist
                          ? pcache.init().then(
                              (_) => pcache.removeFromWatchlist(widget.player))
                          : pcache.init().then(
                              (_) => pcache.addToWatchlist(widget.player)))
                      .then((_) => setState(() => null));
                })
          ]),
          body: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: new List.unmodifiable(
                  widget.player.detailMap().map((p) => new KVText(p))))));
}
