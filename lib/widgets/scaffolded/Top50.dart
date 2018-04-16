import 'dart:async';
import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';

class Top50 extends StatefulWidget {
  final List<int> years;
  Top50(this.years);

  State<StatefulWidget> createState() => new Top50State(years.first);
}

class Top50State extends CheckedSetState<Top50> {
  int year;
  bool _loading = true;
  List<Player> players = [];
  Top50State(this.year);

  refresh() async {
    setState(() {
      _loading = true;
    });
    final p = await dpgsFetchTop50Players("$year");

    setState(() {
      players = p.toList();
      _loading = false;
    });

    await Future.wait(players.map((p) => p.populateAsync()));
    setState(() {});
  }

  initState() {
    super.initState();
    refresh();
  }

  DropdownMenuItem _ddYear(y) =>
      new DropdownMenuItem(value: y, child: new Text("$y"));
  List<DropdownMenuItem> _getYears() => widget.years.map(_ddYear).toList();

  Widget build(BuildContext con) {
    final theme = Theme.of(con);
    return new Scaffold(
        appBar: new AppBar(
            title: new Row(children: [
          new Text("Top Players of"),
          new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Theme(
                  data: theme.copyWith(canvasColor: theme.primaryColor),
                  child: new DropdownButton(
                      style: theme.primaryTextTheme.title,
                      value: year,
                      items: _getYears(),
                      onChanged: (y) {
                        year = y;
                        refresh();
                      }))),
        ])),
        body: _loading
            ? const Center(child: const CircularProgressIndicator())
            : new ListView(
                children:
                    players.map((p) => new PlayerListElement(p)).toList()));
  }
}

class Top50Loader extends StatelessWidget {
  Widget build(BuildContext con) => new AsyncLoader(
        initState: () async => await dpgsFetchTop50Years(),
        renderLoad: () => new Scaffold(
            appBar: new AppBar(title: const Text("Loading Top Players")),
            body: const Center(child: const CircularProgressIndicator())),
        renderError: ([error]) => const Text("ERROR"),
        renderSuccess: ({data}) => new Top50(data.toList()),
      );
}
