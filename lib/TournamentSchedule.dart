import 'package:meta/meta.dart';

import 'package:FlutterBARD/Player.dart';
import 'package:FlutterBARD/Team.dart';
import 'package:FlutterBARD/Tournament.dart';

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

  bool playerIsPlaying(Player p) => playtimesForPlayer(p).isNotEmpty;

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
          rosters: (m['rosters'] ?? [])
              .map((l) => l.map(Player.fromWLEntry).toList())
              .toList(),
          playtimes: (m['playtimes'] ?? [])
              .map((l) => l.map(DateTime.parse).toList())
              .toList());
}
