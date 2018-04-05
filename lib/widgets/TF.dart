import 'package:flutter/material.dart';

class TF extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool password;

  TF(this.label, this.controller, {this.password = false});
  build(BuildContext con) => new TextField(
      decoration: new InputDecoration(labelText: label),
      controller: controller,
      obscureText: password);
}
