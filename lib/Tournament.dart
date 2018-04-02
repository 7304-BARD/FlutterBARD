import 'package:meta/meta.dart';

class Tournament {
  final String title;
  final String date;
  final String location;
  final String id;
  final bool isGroup;

  const Tournament(
      {@required this.id,
      @required this.title,
      @required this.date,
      @required this.location,
      @required this.isGroup});
}
