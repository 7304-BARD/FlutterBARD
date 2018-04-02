import 'package:flutter/material.dart';

import 'package:range/range.dart';

class CalendarUI extends StatefulWidget {
  final DateTime month;
  const CalendarUI(this.month);

  createState() => new CalendarUIState(month);
}

class DaySquare extends StatelessWidget {
  final int offset;
  final int end;
  final bool drawn;
  DaySquare(this.offset, this.end) : drawn = offset > 0 && offset <= end;

  build(BuildContext con) => drawn
      ? new Expanded(
          child: new Container(
              decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.grey, width: 1.0)),
              child: new Text("$offset")))
      : new Expanded(child: new Container());
}

class WeekRow extends StatelessWidget {
  final int offset;
  final int end;
  const WeekRow(this.offset, this.end);

  build(BuildContext con) => new Expanded(
      child: new Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
              range(offset, offset + 7).map((i) => new DaySquare(i, end))));
}

class WeekdayRow extends StatelessWidget {
  const WeekdayRow();

  build(BuildContext con) => new Row(
      children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          .map((l) => new Expanded(
              child: new Center(
                  child: new Text(l,
                      style: const TextStyle(fontWeight: FontWeight.bold)))))
          .toList());
}

class MonthGrid extends StatelessWidget {
  final int offset;
  final int end;
  const MonthGrid(this.offset, this.end);

  build(BuildContext con) => new Column(
      children: [const WeekdayRow()]..addAll(
          range(1 - offset, 1 - offset + 5 * 7, 7)
              .map((i) => new WeekRow(i, end)) as List<WeekRow>));
}

const months = const [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

String _formatMonth(DateTime m) => "${months[m.month - 1]} ${m.year}";

int _monthLen(DateTime m) =>
    const [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m.month - 1];

int _monthStartDay(DateTime m) => new DateTime(m.year, m.month).weekday % 7;

DateTime _prevMonth(DateTime m) => m.month == 1
    ? new DateTime(m.year - 1, 12)
    : new DateTime(m.year, m.month - 1);

DateTime _nextMonth(DateTime m) => m.month == 12
    ? new DateTime(m.year + 1, 1)
    : new DateTime(m.year, m.month + 1);

class CalendarUIState extends State<CalendarUI> {
  DateTime month;
  CalendarUIState(this.month);

  build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(_formatMonth(month)), actions: [
        new IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                month = widget.month;
              });
            }),
        new IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              setState(() {
                month = _prevMonth(month);
              });
            }),
        new IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              setState(() {
                month = _nextMonth(month);
              });
            })
      ]),
      body: new MonthGrid(_monthStartDay(month), _monthLen(month)));
}
