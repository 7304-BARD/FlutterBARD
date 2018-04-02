import 'package:flutter/material.dart';

import 'Tournament.dart';

class TournamentListElementWidget extends StatefulWidget {
  final Tournament tournament;
  final Function onTap;

  const TournamentListElementWidget(this.tournament, this.onTap);
  State<StatefulWidget> createState() => new TournamentListElementWidgetState();
}

class TournamentListElementWidgetState
    extends State<TournamentListElementWidget> {
  Widget build(BuildContext con) => new GestureDetector(
      onTap: widget.onTap,
      child: new Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        new Row(
          children: [
            new Expanded(
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(widget.tournament.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(widget.tournament.date),
            ),
          ],
        ),
        new Padding(
            child: new Text(widget.tournament.location),
            padding: const EdgeInsets.only(right: 8.0)),
      ]));
}
