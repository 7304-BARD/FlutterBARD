import 'dart:async';

import 'package:flutter/material.dart';

import 'package:async_loader/async_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'HomePage.dart';
import 'Login.dart';

void main() => runApp(new MyApp());

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
