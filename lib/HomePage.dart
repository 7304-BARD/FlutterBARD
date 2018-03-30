import 'dart:io';

import 'package:flutter/material.dart';

import 'package:android_intent/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  HomePage(this.user);

  Widget build(BuildContext con) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) { print("onMessage: $message"); },
      onLaunch: (Map<String, dynamic> message) { print("onLaunch: $message"); },
      onResume: (Map<String, dynamic> message) { print("onResume: $message"); },
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(
      sound: true, alert: true, badge: true
    ));

    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("iOS settings registered: $settings");
    });
    
    _firebaseMessaging.getToken().then((String token){
      assert(token != null);
      print("Token: $token");
    });

    return new Scaffold(
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
}
