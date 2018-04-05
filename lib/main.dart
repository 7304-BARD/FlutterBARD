import 'package:flutter/material.dart';

import 'package:async_loader/async_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:FlutterBARD/HomePage.dart';
import 'package:FlutterBARD/Login.dart';

void main() {
  doFBaseMessagingSetup();
  runApp(new MyApp());
}

doFBaseMessagingSetup() {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) {
      print("onMessage: $message");
    },
    onLaunch: (Map<String, dynamic> message) {
      print("onLaunch: $message");
    },
    onResume: (Map<String, dynamic> message) {
      print("onResume: $message");
    },
  );

  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, alert: true, badge: true));

  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("iOS settings registered: $settings");
  });

  _firebaseMessaging.getToken().then((String token) {
    assert(token != null);
    print("Token: $token");
  });
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) => new MaterialApp(
        title: 'BARD',
        theme: new ThemeData(
          primarySwatch: Colors.orange,
          accentColor: const Color(0xffffaabb),
        ),
        home: new AsyncLoader(
          initState: () async => await FirebaseAuth.instance.currentUser(),
          renderLoad: () => new CircularProgressIndicator(),
          renderError: ([error]) => new Text("ERROR"),
          renderSuccess: ({data}) =>
              data == null ? new Login() : new HomePage(data),
        ),
      );
}
