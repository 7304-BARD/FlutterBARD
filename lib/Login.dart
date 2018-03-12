import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'HomePage.dart';

class Login extends StatelessWidget {
  Widget build(BuildContext context) {
    final emailCon = new TextEditingController();
    final passCon = new TextEditingController();
    return new Scaffold(
        appBar: new AppBar(title: new Text("Login")),
        body: new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new Column(
              children: [
                new TextField(
                    decoration: new InputDecoration(labelText: "Email"),
                    controller: emailCon),
                new TextField(
                    decoration: new InputDecoration(labelText: "Password"),
                    obscureText: true,
                    controller: passCon),
                new HPButton('Login', () async {
                  final email = emailCon.text;
                  final password = passCon.text;
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, password: password);
                  Navigator.of(context).pushReplacementNamed('/');
                }),
                new HPButton('Register', () {
                  Navigator.of(context).pushReplacement(
                      new MaterialPageRoute<Null>(
                          builder: (BuildContext con) => new Register()));
                }),
              ],
            )));
  }
}

class Register extends StatelessWidget {
  Widget build(BuildContext context) => new Text("REGISTER PLACEHOLDER");
}
