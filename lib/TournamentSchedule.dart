import 'Player.dart';
import 'Team.dart';

class TournamentSchedule {
  final List<Team> teams;
  final List<List<Player>> rosters;
  final List<List<DateTime>> playtimes;

  const TournamentSchedule(this.teams, this.rosters, this.playtimes);

  Iterable<DateTime> playtimesForPlayer(Player p) sync* {
    for (var i = 0; i < rosters.length; i++)
      if (rosters[i].any((p2) => p2.pgid == p.pgid))
        for (var j = 0; j < playtimes[i].length; j++) yield playtimes[i][j];
  }

  bool playerIsPlaying(Player p) => playtimesForPlayer(p).isNotEmpty;
}
