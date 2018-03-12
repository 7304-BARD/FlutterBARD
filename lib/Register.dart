import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'HomePage.dart';

class Register extends StatefulWidget {
  createState() => new RegisterState();
}

class RegisterState extends State<Register> {
  final nameCon = new TextEditingController();
  final emailCon = new TextEditingController();
  final passCon = new TextEditingController();
  final passConCon = new TextEditingController();
  final orgCon = new TextEditingController();

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Register")),
        body: new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new SingleChildScrollView(
              child: new Column(
                children: [
                  new TextField(
                      decoration: new InputDecoration(labelText: "Name"),
                      controller: nameCon),
                  new TextField(
                      decoration: new InputDecoration(labelText: "Email"),
                      controller: emailCon),
                  new TextField(
                      decoration: new InputDecoration(labelText: "Password"),
                      obscureText: true,
                      controller: passCon),
                  new TextField(
                      decoration:
                          new InputDecoration(labelText: "Confirm password"),
                      obscureText: true,
                      controller: passConCon),
                  new TextField(
                      decoration:
                          new InputDecoration(labelText: "Organization"),
                      controller: orgCon),
                  new HPButton("Submit", () async {
                    if (passCon.text == passConCon.text) {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailCon.text, password: passCon.text);
                      Navigator.of(context).pop();
                    } else {
                      // TODO
                    }
                  }),
                ],
              ),
            )));
  }
}
