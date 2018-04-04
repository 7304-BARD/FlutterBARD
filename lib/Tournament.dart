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
}
