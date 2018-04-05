import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/scaffolded/CalendarUI.dart';
import 'package:FlutterBARD/widgets/scaffolded/Top50.dart';
import 'package:FlutterBARD/widgets/scaffolded/Tournaments.dart';
import 'package:FlutterBARD/widgets/scaffolded/Watchlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HPButton extends StatelessWidget {
  final String label;
  final Function handler;

  HPButton(this.label, this.handler);

  Widget build(BuildContext con) => new Padding(
      padding: new EdgeInsets.all(10.0),
      child: new RaisedButton(
        color: Theme.of(con).accentColor,
        child: new Text(label),
        onPressed: handler,
      ));
}

class HPNavButton extends StatelessWidget {
  final String label;
  final WidgetBuilder builder;
  HPNavButton(this.label, this.builder);

  Widget build(BuildContext con) => new HPButton(label, tapNav(builder, con));
}

class HomePage extends StatelessWidget {
  final FirebaseUser user;
  HomePage(this.user);

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("BARD"), actions: [
        new IconButton(
            icon: new Icon(Icons.lock),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(con).pushReplacementNamed('/');
            })
      ]),
      body: new ListView(padding: new EdgeInsets.all(20.0), children: [
        new HPNavButton("My Calendar",
            (BuildContext con) => new CalendarUI(new DateTime.now())),
        new HPNavButton("My Watchlist", (BuildContext con) => new Watchlist()),
        new HPNavButton(
            "Top Players by Year", (BuildContext con) => new Top50()),
        new HPNavButton("Tournaments", (BuildContext con) => new Tournaments()),
      ]));
}
