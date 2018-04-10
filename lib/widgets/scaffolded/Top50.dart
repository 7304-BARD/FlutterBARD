import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:flutter/material.dart';

class Top50 extends StatefulWidget {
  State<StatefulWidget> createState() => new Top50State();
}

class Top50State extends State<Top50> {
  static final int yearNow = new DateTime.now().year;
  int year = new DateTime.now().year;
  List<int> _years = [yearNow];
  List<Player> players = [];

  makeYears() async {
    final years = await dpgsFetchTop50Years();

    setState(() {
      _years = years.toList();
    });
  }

  refresh() async {
    final p = await dpgsFetchTop50Players("$year");

    setState(() {
      players = p.toList();
    });
  }

  initState() {
    super.initState();
    makeYears();
    refresh();
  }

  _ddYear(y) => new DropdownMenuItem(value: y, child: new Text("$y"));
  _getYears() => _years.map(_ddYear).toList();

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(
          title: new Row(children: [
        new Text("Top Players of"),
        new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Theme(
                data: Theme
                    .of(con)
                    .copyWith(canvasColor: Theme.of(con).primaryColor),
                child: new DropdownButton(
                    style: Theme.of(con).primaryTextTheme.title,
                    value: year,
                    items: _getYears(),
                    onChanged: (y) {
                      year = y;
                      refresh();
                    }))),
      ])),
      body: new ListView(
          children: new List.unmodifiable(
              players.map((p) => new PlayerListElement(p)))));
}
