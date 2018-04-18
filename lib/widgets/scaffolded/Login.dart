import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:FlutterBARD/widgets/HPButton.dart';
import 'package:FlutterBARD/widgets/Logo.dart';
import 'package:FlutterBARD/widgets/TF.dart';
import 'package:FlutterBARD/widgets/scaffolded/Register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  createState() => new LoginState();
}

class LoginState extends CheckedSetState<Login> {
  final emailCon = new TextEditingController();
  final passCon = new TextEditingController();

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Login")),
        body: new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new ListView(
              children: [
                const Logo(),
                new TF("Email", emailCon),
                new TF("Password", passCon, password: true),
                new Center(
                    child: new HPButton('Login', () async {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailCon.text, password: passCon.text);
                  Navigator.of(context).pushReplacementNamed('/');
                })),
                new Center(
                    child: new HPNavButton(
                        'Register', (BuildContext con) => new Register())),
              ],
            )));
  }
}
