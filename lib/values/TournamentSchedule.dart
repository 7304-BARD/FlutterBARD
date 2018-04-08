import 'dart:math';

import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:meta/meta.dart';
import 'package:range/range.dart';

class TournamentSchedule {
  final Tournament tournament;
  final List<Team> teams;
  final List<List<Player>> rosters;
  final List<List<DateTime>> playtimes;

  const TournamentSchedule(
      {@required this.tournament,
      @required this.teams,
      @required this.rosters,
      @required this.playtimes});

  Iterable<DateTime> playtimesForPlayer(Player p) sync* {
    for (var i = 0; i < rosters.length; i++)
      if (rosters[i].any((p2) => p2.pgid == p.pgid))
        for (var j = 0; j < playtimes[i].length; j++) yield playtimes[i][j];
  }

  Iterable<DateTime> get dates =>
      tournament.dates.length > 7 ? [] : tournament.dates;

  bool playerIsPlaying(Player p) => playtimesForPlayer(p).isNotEmpty;

  bool get hasFullRosters =>
      teams.isNotEmpty && rosters.every((r) => r.isNotEmpty);

  Iterable<DateTime> get flatPlaytimes => playtimes.expand((l) => l);

  Map<String, dynamic> toMap() => {
        'tournament': tournament.toMap(),
        'teams': teams.map((t) => t.toMap()).toList(),
        'rosters':
            rosters.map((l) => l.map((p) => p.toWLEntry()).toList()).toList(),
        'playtimes':
            playtimes.map((l) => l.map((d) => d.toString()).toList()).toList(),
      };

  static TournamentSchedule fromMap(Map<String, dynamic> m) =>
      new TournamentSchedule(
          tournament: new Tournament.fromMap(m['tournament']),
          teams: (m['teams'] ?? []).map(Team.fromMap).toList(),
          rosters: (_listify(m['rosters']) ?? [])
              .map((l) => (l ?? []).map(Player.fromWLEntry).toList())
              .toList(),
          playtimes: (_listify(m['playtimes']) ?? [])
              .map((l) => (l ?? []).map(DateTime.parse).toList())
              .toList());
}

List _listify(o) {
  if (o is List)
    return o;
  else if (o is Map) {
    final int length = o.keys.map((s) => int.parse(s)).fold(-1, max) + 1;
    return range(length).map((i) => o[i]).toList();
  } else
    return [];
}
