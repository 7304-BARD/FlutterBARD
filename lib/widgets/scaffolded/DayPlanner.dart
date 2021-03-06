import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:FlutterBARD/widgets/CheckedSetState.dart';
import 'package:FlutterBARD/widgets/PlayerListElement.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:url_launcher/url_launcher.dart';

class DayPlanner extends StatefulWidget {
  final List<TournamentSchedule> scheds;
  final List<Player> watchlist;
  final DateTime day;

  DayPlanner(
      {@required this.scheds, @required this.watchlist, @required this.day});

  createState() => new DayPlannerState(day);
}

class DayPlannerState extends CheckedSetState<DayPlanner> {
  DateTime day;
  DayPlannerState(this.day);

  void _nextDay() {
    setState(() {
      day = day.add(const Duration(days: 1));
    });
  }

  void _previousDay() {
    setState(() {
      day = day.subtract(const Duration(days: 1));
    });
  }

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(Dates.formatShort(day)), actions: [
        new IconButton(
            icon: const Icon(Icons.navigate_before), onPressed: _previousDay),
        new IconButton(
            icon: const Icon(Icons.navigate_next), onPressed: _nextDay)
      ]),
      body: new Dismissible(
          onDismissed: (DismissDirection dir) {
            if (dir == DismissDirection.startToEnd)
              _previousDay();
            else
              _nextDay();
          },
          key: new ObjectKey(new DateTime.now()),
          child: new ListView(
              children: (widget.scheds
                      .map((s) => s.matchupRosters)
                      .expand((l) => l)
                      .where((mr) => Dates.isSameDay(day, mr.matchup.playtime))
                      .toList()
                        ..sort())
                  .map((mr) => new MatchupRosterListing(mr, widget.watchlist))
                  .toList())));
}

class MatchupRosterListing extends StatelessWidget {
  final MatchupRosters matchupRosters;
  final List<Player> watchlist;

  MatchupRosterListing(this.matchupRosters, this.watchlist);

  Widget build(BuildContext con) {
    final watchedPlayers = matchupRosters.matchup.teams
        .map((t) => matchupRosters.rosters[t.id])
        .where((l) => l != null)
        .expand((l) => l)
        .where((p) => watchlist.any((p2) => p2.pgid == p.pgid));
    return new TapNav(
        builder: (BuildContext Con) => new RosterListing(matchupRosters),
        child: new Container(
            decoration: new BoxDecoration(
                color: watchedPlayers.isNotEmpty
                    ? Theme.of(con).accentColor
                    : null,
                border: new Border.all(
                    color: Theme.of(con).dividerColor, width: 1.0)),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[new MatchupListing(matchupRosters)]..addAll(
                    watchedPlayers.map((p) => new Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: new PlayerListElement(p)))))));
  }
}

class MatchupListing extends StatelessWidget {
  final MatchupRosters matchupRosters;

  MatchupListing(this.matchupRosters);

  Widget build(BuildContext con) => new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ([
          Dates.formatTime(matchupRosters.matchup.playtime),
          matchupRosters.tournament.location,
          matchupRosters.matchup.location
        ]..addAll(matchupRosters.matchup.teams.map((t) => t.name)))
            .map((s) => new Text(s))
            .toList(),
      ));
}

class RosterListing extends StatelessWidget {
  final MatchupRosters matchupRosters;
  RosterListing(this.matchupRosters);

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(
          title: new Text(Dates.formatLong(matchupRosters.matchup.playtime)),
          actions: matchupRosters.matchup.maplink == null
              ? []
              : [
                  new IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () => launch(matchupRosters.matchup.maplink))
                ]),
      body: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new ListView(
              children: [
            new Text(matchupRosters.tournament.location),
            new Text(matchupRosters.matchup.location)
          ]..addAll(matchupRosters.matchup.teams
                  .map((t) => new _RosterListingTeam(matchupRosters, t))))));
}

class _RosterListingTeam extends StatelessWidget {
  final String name;
  final List<Player> players;
  _RosterListingTeam(MatchupRosters mr, Team t)
      : name = t.name,
        players = mr.rosters[t.id] {
    Future.wait(players?.map((p) => p.populateAsync()) ?? []).then((_) {});
  }

  Widget build(BuildContext con) => new Column(
      children: [new Text(name)]..addAll(
          players?.map((p) => new PlayerListElement(p)) ??
              [
                new Text("Roster Not Available",
                    style: const TextStyle(color: Colors.red))
              ]));
}
