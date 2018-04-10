import 'package:meta/meta.dart';
import 'package:FlutterBARD/dates.dart';

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

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'location': location,
        'id': id,
        'isGroup': isGroup ? 1 : 0
      };

  Tournament.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        title = m['title'],
        location = m['location'],
        date = m['date'],
        isGroup = m['isGroup'] > 0;

  Iterable<DateTime> get dates sync* {
    final now = new DateTime.now();
    final startEnd = date.split('-');
    final start = Dates.parsePGShort(startEnd[0], now.year, now.month);
    final end = startEnd.length > 1
        ? Dates.parsePGShort(startEnd[1], start.year, start.month)
        : start;
    for (int i = 0; i < end.difference(start).inDays + 1; i++)
      yield start.add(new Duration(days: i));
  }
}
