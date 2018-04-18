import 'package:FlutterBARD/misc.dart';
import 'package:FlutterBARD/widgets/scaffolded/HomePage.dart';
import 'package:FlutterBARD/widgets/scaffolded/Login.dart';
import 'package:async_loader/async_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() {
  //doFBaseMessagingSetup();
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

final _colorsBuzzGold = const MaterialColor(0xffeaaa00, const {
  50: const Color(0xffFCF5E0),
  100: const Color(0xffF9E6B3),
  200: const Color(0xffF5D580),
  300: const Color(0xffF0C44D),
  400: const Color(0xffEDB726),
  500: const Color(0xffEAAA00),
  600: const Color(0xffE7A300),
  700: const Color(0xffE49900),
  800: const Color(0xffE19000),
  900: const Color(0xffDB7F00),
});

final _colorsTechBlue = const MaterialColor(0xff003057, const {
  50: const Color(0xffe0e6eb),
  100: const Color(0xffb3c1cd),
  200: const Color(0xff8098ab),
  300: const Color(0xff4d6e89),
  400: const Color(0xff264f70),
  500: const Color(0xff003057),
  600: const Color(0xff002b4f),
  700: const Color(0xff002446),
  800: const Color(0xff001e3c),
  900: const Color(0xff00132c),
});

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) => new MaterialApp(
        title: appTitle,
        theme: new ThemeData(
          primarySwatch: _colorsTechBlue,
          accentColor: _colorsBuzzGold,
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
