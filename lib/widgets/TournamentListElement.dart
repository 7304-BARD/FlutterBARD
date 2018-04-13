import 'package:FlutterBARD/values/Tournament.dart';
import 'package:flutter/material.dart';

class TournamentListElement extends StatelessWidget {
  final Tournament tournament;
  final Function onTap;

  const TournamentListElement(this.tournament, this.onTap);

  Widget build(BuildContext con) => new GestureDetector(
      onTap: onTap,
      child: new Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        new Row(
          children: [
            new Expanded(
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(tournament.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(tournament.date),
            ),
          ],
        ),
        new Padding(
            child: new Text(tournament.location),
            padding: const EdgeInsets.only(right: 8.0)),
      ]));
}
