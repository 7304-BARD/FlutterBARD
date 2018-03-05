import 'dart:io';

import 'package:flutter/material.dart';

import 'package:android_intent/android_intent.dart';

import 'Top50.dart';

class HomePage extends StatelessWidget {
    Widget build(BuildContext con) => new Scaffold(
        appBar: new AppBar(title: new Text("BARD")),
        body: new ListView(
            padding: new EdgeInsets.all(20.0),
            children: [
                new RaisedButton(
                    color: Theme.of(con).accentColor,
                    child: new Text("My Calendar"),
                    onPressed: () {},
                ),
                new RaisedButton(
                    color: Theme.of(con).accentColor,
                    child: new Text("My Watchlist"),
                    onPressed: () {},
                ),
                new RaisedButton(
                    color: Theme.of(con).accentColor,
                    child: new Text("Top 50"),
                    onPressed: () {
                        Navigator.of(con).push(new MaterialPageRoute<Null>(
                            builder: (BuildContext con) => new Top50("2016"),
                        ));
                    },
                ),
                new RaisedButton(
                    color: Theme.of(con).accentColor,
                    child: new Text("Map"),
                    onPressed: () {
                        if (Platform.isAndroid) {
                            new AndroidIntent(
                                action: 'action_view',
                                data: 'https://www.google.com/maps/dir/?api=1&destination_place_id=ChIJv78fsWEE9YgR3Zqua8Olkw0&destination=Russ+Chandler+Stadium'
                            ).launch();
                        }
                    },
                ),
                new RaisedButton(
                    color: Theme.of(con).accentColor,
                    child: new Text("Tournaments"),
                    onPressed: () {},
                ),
            ]
        )
    );
}
