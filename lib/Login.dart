import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:FlutterBARD/HomePage.dart';
import 'package:FlutterBARD/Register.dart';

class Login extends StatefulWidget {
  createState() => new LoginState();
}

class LoginState extends State<Login> {
  final emailCon = new TextEditingController();
  final passCon = new TextEditingController();

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Login")),
        body: new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new Column(
              children: [
                new TF("Email", emailCon),
                new TF("Password", passCon, password: true),
                new HPButton('Login', () async {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailCon.text, password: passCon.text);
                  Navigator.of(context).pushReplacementNamed('/');
                }),
                new HPNavButton(
                    'Register', (BuildContext con) => new Register()),
              ],
            )));
  }
}
