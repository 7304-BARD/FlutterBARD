import 'package:FlutterBARD/values/Matchup.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/Team.dart';
import 'package:FlutterBARD/values/Tournament.dart';
import 'package:meta/meta.dart';

@immutable
class TournamentSchedule {
  final Tournament tournament;
  final List<Matchup> matchups;
  final Map<String, List<Player>> rosters;

  const TournamentSchedule(
      {@required this.tournament,
      @required this.rosters,
      @required this.matchups});

  Iterable<DateTime> playtimesForPlayer(Player p) {
    final playerTeams = teams
        .where((t) => rosters[t.id]?.any((p2) => p2.pgid == p.pgid) ?? false)
        .toList();
    return matchups
        .where(
            (m) => m.teams.any((t) => playerTeams.any((t2) => t2.id == t.id)))
        .map((m) => m.playtime);
  }

  Set<Team> get teams =>
      new Set.from(matchups.map((m) => m.teams).expand((l) => l));

  Iterable<DateTime> get dates =>
      tournament.dates.length > 7 ? [] : tournament.dates;

  bool playerIsPlaying(Player p) => playtimesForPlayer(p).isNotEmpty;

  bool get hasFullRosters =>
      teams.isNotEmpty && rosters.values.every((r) => r.isNotEmpty);

  Iterable<DateTime> get flatPlaytimes => matchups.map((m) => m.playtime);

  Iterable<MatchupRosters> get matchupRosters => matchups.map((m) =>
      new MatchupRosters(matchup: m, rosters: rosters, tournament: tournament));

  Map<String, dynamic> toMap() => {
        'tournament': tournament.toMap(),
        'rosters': new Map.fromIterables(rosters.keys,
            rosters.values.map((l) => l.map((p) => p.toWLEntry()).toList())),
        'matchups': matchups.map((m) => m.toMap()).toList()
      };

  static List<Player> _playersFromWLE(dynamic l) =>
      l.map<Player>(Player.fromWLEntry).toList();

  static TournamentSchedule fromMap(dynamic m) => new TournamentSchedule(
      tournament: new Tournament.fromMap(m['tournament']),
      rosters: new Map.fromIterables(
          m['rosters']?.keys?.cast<String>() ?? <String>[],
          m['rosters']?.values?.map<List<Player>>(_playersFromWLE) ?? []),
      matchups: m['matchups']?.map<Matchup>(Matchup.fromMap)?.toList() ??
          <Matchup>[]);
}

@immutable
class MatchupRosters extends Comparable<MatchupRosters> {
  final Tournament tournament;
  final Matchup matchup;
  final Map<String, List<Player>> rosters;

  MatchupRosters(
      {@required this.matchup,
      @required this.rosters,
      @required this.tournament});

  int compareTo(MatchupRosters m) => matchup.compareTo(m.matchup);
}
