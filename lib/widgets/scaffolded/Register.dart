import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:FlutterBARD/widgets/HPButton.dart';
import 'package:FlutterBARD/widgets/TF.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  createState() => new RegisterState();
}

class RegisterState extends CheckedSetState<Register> {
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
                  new TF("Name", nameCon),
                  new TF("Email", emailCon),
                  new TF("Password", passCon, password: true),
                  new TF("Confirm password", passConCon, password: true),
                  new TF("Organization", orgCon),
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
