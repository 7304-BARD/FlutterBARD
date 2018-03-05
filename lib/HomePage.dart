import 'dart:io';

import 'package:flutter/material.dart';

import 'package:android_intent/android_intent.dart';

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

class HomePage extends StatelessWidget {
  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text("BARD")),
      body: new ListView(padding: new EdgeInsets.all(20.0), children: [
        new HPButton("My Calendar", null),
        new HPButton("My Watchlist", () {
          Navigator.of(con).push(new MaterialPageRoute<Null>(
              builder: (BuildContext con) => new Watchlist()));
        }),
        new HPButton(
          "Top 50",
          () {
            Navigator.of(con).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext con) => new Top50("2016"),
                ));
          },
        ),
        new HPButton(
          "Map",
          () {
            if (Platform.isAndroid) {
              new AndroidIntent(
                      action: 'action_view',
                      data:
                          'https://www.google.com/maps/dir/?api=1&destination_place_id=ChIJv78fsWEE9YgR3Zqua8Olkw0&destination=Russ+Chandler+Stadium')
                  .launch();
            }
          },
        ),
        new HPButton(
          "Tournaments",
          () {
            Navigator.of(con).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext con) => new Tournaments(),
                ));
          },
        ),
      ]));
}
