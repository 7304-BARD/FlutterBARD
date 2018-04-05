import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:flutter/material.dart';

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

  Widget build(BuildContext con) => new HPButton(label, tapNav(builder, con));
}
