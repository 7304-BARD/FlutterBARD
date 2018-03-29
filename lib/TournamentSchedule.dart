import 'Player.dart';
import 'Team.dart';

class TournamentSchedule {
  final List<Team> teams;
  final List<List<Player>> rosters;
  final List<List<String>> playtimes;

  TournamentSchedule(this.teams, this.rosters, this.playtimes);
}
