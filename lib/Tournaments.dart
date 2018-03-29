import 'package:flutter/material.dart';

import 'dpgs.dart';
import 'HomePage.dart';
import 'Player.dart';
import 'PlayerListElementWidget.dart';
import 'Team.dart';
import 'TournamentListElementWidget.dart';
import 'Tournament.dart';

class Tournaments extends StatefulWidget {
  State<StatefulWidget> createState() => new TournamentsState();
  Tournaments();
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
      appBar: new AppBar(title: new Text("Tournaments")),
      body: new ListView(
          children: new List.unmodifiable(
              tournaments.map((t) => new TournamentListElementWidget(t, () {
                    Navigator.of(con).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext con) =>
                            new TournamentTeamListing(t)));
                  })))));
}

class TeamListElement extends StatelessWidget {
  final Team t;
  TeamListElement(this.t);

  build(BuildContext con) =>
      new HPNavButton(t.name, (BuildContext c) => new TeamRosterListing(t));
}

class TournamentTeamListing extends StatefulWidget {
  final Tournament tournament;
  TournamentTeamListing(this.tournament);

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
          children: teams.map((t) => new TeamListElement(t)).toList()));
}

class TeamRosterListing extends StatefulWidget {
  final Team team;
  TeamRosterListing(this.team);

  createState() => new TeamRosterListingState();
}

class TeamRosterListingState extends State<TeamRosterListing> {
  List<Player> players = [];

  initState() {
    super.initState();
    dpgsGetTournamentTeamPage(widget.team)
        .then((d) => dpgsGetTournamentTeamRoster(d))
        .then((p) {
      setState(() {
        players = p.toList();
      });
    });
  }

  build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(widget.team.name)),
      body: new ListView(
          children:
              players.map((p) => new PlayerListElementWidget(p)).toList()));
}
