import 'package:meta/meta.dart';

import 'package:FlutterBARD/values/Team.dart';

@immutable
class Matchup implements Comparable<Matchup> {
  final String gameid;
  final DateTime playtime;
  final String location;
  final List<Team> teams;

  Matchup(
      {@required this.gameid,
      @required this.playtime,
      @required this.location,
      @required this.teams});

  int compareTo(Matchup m) => playtime.compareTo(m.playtime);

  Map<String, dynamic> toMap() => {
        'gameid': gameid,
        'playtime': playtime.toString(),
        'location': location,
        'teams': teams.map((t) => t.toMap()).toList()
      };

  static Matchup fromMap(dynamic m) => new Matchup(
      gameid: m['gameid'],
      playtime: DateTime.parse(m['playtime']),
      location: m['location'],
      teams: m['teams']?.map<Team>(Team.fromMap)?.toList() ?? <Team>[]);
}
