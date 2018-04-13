import 'package:meta/meta.dart';
import 'package:FlutterBARD/dates.dart';

class Tournament {
  final String title;
  final String date; // may be a range of dates. See [dates] property.
  final String location; // general location, such as a city
  final String id;

  // Most tournaments are event groups, which contain several sub-events.
  // dpgs handles both single events and groups.
  // isGroup distinguishes which kind of [id] we have.
  final bool isGroup;

  const Tournament(
      {@required this.id,
      @required this.title,
      @required this.date,
      @required this.location,
      @required this.isGroup});

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'location': location,
        'id': id,
        'isGroup': isGroup ? 1 : 0
      };

  Tournament.fromMap(dynamic m)
      : id = m['id'],
        title = m['title'],
        location = m['location'],
        date = m['date'],
        isGroup = m['isGroup'] > 0;

  /// yield a DateTime for each day of the tournament.
  Iterable<DateTime> get dates sync* {
    final now = new DateTime.now(); // PG omits years, so substitute our own.
    final startEnd = date.split('-'); // date may be a single day, or range
    final start = Dates.parsePGShort(startEnd[0], now.year, now.month);
    final end = startEnd.length > 1
        ? Dates.parsePGShort(startEnd[1], start.year, start.month)
        : start;
    for (int i = 0; i < end.difference(start).inDays + 1; i++)
      yield start.add(new Duration(days: i));
  }
}
