import 'dart:async';
import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:FlutterBARD/widgets/Loader.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/TournamentListElement.dart';
import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Tournaments extends StatefulWidget {
  State<StatefulWidget> createState() => new TournamentsState();
}

class TournamentsState extends CheckedSetState<Tournaments> {
  Map<String, String> _years = {};
  final Map<String, String> _months = dpgsGetTournamentFilterMonths();
  String _year;
  List<Tournament> _data = [];
  String _month = Dates.getCurrentMonth();
  Map<String, String> _postParameters =
      dpgsGetDefaultTournamentPostParameters();
  bool _doPost = false;

  DropdownMenuItem getDropdownItem(String text) =>
      new DropdownMenuItem(child: new Text(text), value: text);

  List<DropdownMenuItem> getDropdownList(Iterable<String> keys) =>
      keys.map(getDropdownItem).toList();

  void _getFilterYears() async {
    _years = await dpgsGetTournamentFilterYears();
    setState(() {
      _year = Dates.getCurrentYear();
    });
    _getTournamentsData();
  }

  void _getTournamentsData() async {
    _data = (_doPost
            ? await dpgsPostTournamentsData(_postParameters)
            : await dpgsFetchTournamentsData(params: _postParameters))
        .toList();
    debugPrint("_data updated");
    setState(() {});
  }

  void initState() {
    super.initState();
    _getFilterYears();
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: const Text("Tournaments")),
      body: _year == null
          ? const Center(child: const CircularProgressIndicator())
          : new Column(children: <Widget>[
              new DropdownButton(
                  items: getDropdownList(_years.keys),
                  value: _year,
                  onChanged: (newValue) {
                    _year = newValue;
                  }),
              new DropdownButton(
                  items: getDropdownList(_months.keys),
                  value: _month,
                  onChanged: (newValue) {
                    _month = newValue;
                    debugPrint('_month changed to $newValue');
                    _postParameters["__EVENTTARGET"] = _months[newValue];
                    _doPost = true;
                    _getTournamentsData();
                  }),
              new Expanded(
                  child: new ListView(
                      children: _data
                          .map((t) => new TournamentListElement(
                              t,
                              tapNav(
                                  (BuildContext con) =>
                                      new TournamentTeamListing(t),
                                  con)))
                          .toList()))
            ]));
}

class TeamListElement extends StatelessWidget {
  final Team team;
  final Tournament tournament;
  const TeamListElement(this.team, this.tournament);

  build(BuildContext con) => new TapNav(
      child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(team.name,
              style: const TextStyle(fontWeight: FontWeight.bold))),
      builder: (BuildContext con) => new TeamRosterListing(team, tournament));
}

class TournamentTeamListing extends StatelessWidget {
  final Tournament tournament;
  const TournamentTeamListing(this.tournament);

  build(BuildContext con) => new LoaderScaffold(
        title: tournament.title,
        initState: () async => dpgsFetchTournamentTeams(tournament),
        renderSuccess: ({data}) => new ListView(
            children: (data as List<Team>)
                .map((t) => new TeamListElement(t, tournament))
                .toList()),
      );
}

class TeamRosterListing extends StatelessWidget {
  final Team team;
  final Tournament tournament;
  const TeamRosterListing(this.team, this.tournament);

  Future<Tuple2<List<Player>, List<DateTime>>> fetchDoc() async {
    final doc = await dpgsFetchTournamentTeamPage(team);
    final players = dpgsGetTournamentTeamRoster(doc).toList();
    final playtimes = dpgsGetTournamentTeamPlaytimes(doc).toList();
    return new Tuple2<List<Player>, List<DateTime>>(players, playtimes);
  }

  static Widget _view(Tuple2<List<Player>, List<DateTime>> data) =>
      new ListView(
          children: []
            ..addAll(data.item2.map((p) => new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(Dates.formatLong(p)))))
            ..addAll(data.item1.map((p) => new PlayerListElement(p))));

  build(BuildContext con) => new LoaderScaffold(
      title: team.name,
      initState: fetchDoc,
      renderSuccess: ({data}) => _view(data));
}
