import 'package:flutter/material.dart';

import 'dpgs.dart';
import 'TournamentListElementWidget.dart';
import 'Tournament.dart';

class Tournaments extends StatefulWidget {
  State<StatefulWidget> createState() => new TournamentsState();
  Tournaments();
}

class TournamentsState extends State<Tournaments> {
  List<Tournament> tournaments = [];

  initState() {
    super.initState();
    dpgsGetTournamentsData().then((t) {
      setState(() {
        tournaments = new List.unmodifiable(t);
      });
    });
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Tournaments")),
      body: new ListView(
          children: new List.unmodifiable(tournaments
              .map((p) => new TournamentListElementWidget(p, () {})))));
}
