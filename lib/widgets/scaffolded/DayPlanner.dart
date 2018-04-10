import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/values/Matchup.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:FlutterBARD/widgets/scaffolded/PlayerDetail.dart';

class DayPlanner extends StatelessWidget {
  final List<TournamentSchedule> scheds;
  final List<Player> watchlist;
  final DateTime day;

  DayPlanner(
      {@required this.scheds, @required this.watchlist, @required this.day});

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(Dates.formatShort(day))),
      body: new ListView(
          children:
              (scheds.map((s) => s.matchupRosters).expand((l) => l).toList()
                    ..sort())
                  .map((mr) => new MatchupRosterListing(mr, watchlist))
                  .toList()));
}

class MatchupRosterListing extends StatelessWidget {
  final MatchupRosters matchupRosters;
  final List<Player> watchlist;

  MatchupRosterListing(this.matchupRosters, this.watchlist);

  Widget build(BuildContext con) => new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.lime, width: 1.0)),
      child: new Column(
          children: <Widget>[new MatchupListing(matchupRosters.matchup)]
            ..addAll(matchupRosters.matchup.teams
                .map((t) => matchupRosters.rosters[t.id])
                .where((l) => l != null)
                .expand((l) => l)
                .where((p) => watchlist.any((p2) => p2.pgid == p.pgid))
                .map((p) => new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: new PlayerListElement(p))))));
}

class MatchupListing extends StatelessWidget {
  final Matchup matchup;

  MatchupListing(this.matchup);

  Widget build(BuildContext con) => new Container(
          child: new Column(
              children: [
        new KVText(
            new Tuple2(Dates.formatLong(matchup.playtime), matchup.location)),
        matchup.teams.length >= 2
            ? new KVText(
                new Tuple2(matchup.teams[0].name, matchup.teams[1].name))
            : null
      ].where((w) => w != null).toList()));
}
