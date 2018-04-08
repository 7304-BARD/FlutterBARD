import 'package:meta/meta.dart';
import 'package:range/range.dart';

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
    final start = _parseDateAbbrev(startEnd[0], now.year, now.month);
    final end = startEnd.length > 1
        ? _parseDateAbbrev(startEnd[1], start.year, start.month)
        : start;
    for (int i in range(end.difference(start).inDays + 1))
      yield start.add(new Duration(days: i));
  }
}

DateTime _parseDateAbbrev(String d, int year, int defaultMonth) {
  final match = new RegExp(r'^((...)\s+)?(\d\d?)$').firstMatch(d);
  final month = _parseShortMonth(match[2]);
  return new DateTime(
      year, month > 0 ? month : defaultMonth, int.parse(match[3]));
}

int _parseShortMonth(String m) =>
    const [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ].indexOf(m) +
    1;
