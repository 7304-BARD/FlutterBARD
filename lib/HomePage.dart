import 'dart:io';

import 'package:flutter/material.dart';

import 'package:android_intent/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Top50.dart';
import 'Tournaments.dart';
import 'Watchlist.dart';

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

  Widget build(BuildContext con) => new HPButton(label, () {
        Navigator.of(con).push(new MaterialPageRoute<Null>(builder: builder));
      });
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
        new HPButton("My Calendar", null),
        new HPNavButton("My Watchlist", (BuildContext con) => new Watchlist()),
        new HPNavButton("Top 50", (BuildContext con) => new Top50("2016")),
        new HPNavButton("Tournaments", (BuildContext con) => new Tournaments()),
      ]));
}
