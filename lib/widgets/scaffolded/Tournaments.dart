import 'package:FlutterBARD/data_access/dpgs.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/TournamentListElement.dart';
import 'package:flutter/material.dart';

class Tournaments extends StatefulWidget {
  State<StatefulWidget> createState() => new TournamentsState();
  const Tournaments();
}

class TournamentsState extends State<Tournaments> {
  List<Tournament> tournaments = [];

  initState() {
    super.initState();
    dpgsGetTournamentsData().then((t) {
      setState(() {
        tournaments = new List.unmodifiable(t);
      });
    });
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: const Text("Tournaments")),
      body: new ListView(
          children: new List.unmodifiable(tournaments.map((t) =>
              new TournamentListElement(
                  t,
                  tapNav((BuildContext con) => new TournamentTeamListing(t),
                      con))))));
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

class TournamentTeamListing extends StatefulWidget {
  final Tournament tournament;
  const TournamentTeamListing(this.tournament);

  createState() => new TournamentTeamListingState();
}

class TournamentTeamListingState extends State<TournamentTeamListing> {
  List<Team> teams = [];
  initState() {
    super.initState();
    dpgsGetTournamentTeams(widget.tournament).then((l) {
      setState(() => teams = l);
    });
  }

  build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(widget.tournament.title)),
      body: new ListView(
          children: teams
              .map((t) => new TeamListElement(t, widget.tournament))
              .toList()));
}

class TeamRosterListing extends StatefulWidget {
  final Team team;
  final Tournament tournament;
  const TeamRosterListing(this.team, this.tournament);

  createState() => new TeamRosterListingState();
}

class TeamRosterListingState extends State<TeamRosterListing> {
  List<Player> players = [];
  List<DateTime> playtimes = [];

  void fetchDoc() async {
    final doc = await dpgsGetTournamentTeamPage(widget.team);
    playtimes = dpgsGetTournamentTeamPlaytimes(doc).toList();
    setState(() {
      players = dpgsGetTournamentTeamRoster(doc).toList();
    });
  }

  initState() {
    super.initState();
    fetchDoc();
  }

  build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(widget.team.name)),
      body: new ListView(
          children: []
            ..addAll(playtimes.map((p) => new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(p.toIso8601String()))))
            ..addAll(players.map((p) => new PlayerListElement(p)))));
}
