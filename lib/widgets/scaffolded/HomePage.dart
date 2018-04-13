import 'package:FlutterBARD/widgets/HPButton.dart';
import 'package:FlutterBARD/widgets/scaffolded/CalendarUI.dart';
import 'package:FlutterBARD/widgets/scaffolded/Top50.dart';
import 'package:FlutterBARD/widgets/scaffolded/Tournaments.dart';
import 'package:FlutterBARD/widgets/scaffolded/Watchlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final FirebaseUser user;
  HomePage(this.user);

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("Wreck Cards"), actions: [
        new IconButton(
            icon: new Icon(Icons.lock),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(con).pushReplacementNamed('/');
            })
      ]),
      body: new ListView(padding: new EdgeInsets.all(20.0), children: [
        new HPNavButton("Event Calendar",
            (BuildContext con) => new CalendarUI(new DateTime.now())),
        new HPNavButton("My Watchlist", (BuildContext con) => new Watchlist()),
        new HPNavButton(
            "Top Players by Year", (BuildContext con) => new Top50()),
        new HPNavButton("Tournaments", (BuildContext con) => new Tournaments()),
      ]));
}
