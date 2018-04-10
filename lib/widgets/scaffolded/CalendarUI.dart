import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:range/range.dart';

import 'package:FlutterBARD/dates.dart';
import 'package:FlutterBARD/data_access/PlayerCache.dart';
import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/values/TournamentSchedule.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/scaffolded/DayPlanner.dart';

class CalendarUI extends StatefulWidget {
  final DateTime month;
  const CalendarUI(this.month);

  createState() => new CalendarUIState(month);
}

const _watchlistEvent = const Icon(Icons.stars, color: Colors.purple);
const _eventWithRoster = const Icon(Icons.place, color: Colors.cyan);
const _eventNoRoster =
    const Icon(Icons.not_listed_location, color: Colors.green);

class DaySquare extends StatelessWidget {
  final DateTime month;
  final DateTime day;
  const DaySquare(this.month, this.day);

  bool get drawn => month.month == day.month;

  build(BuildContext con) {
    if (drawn) {
      final children = <Widget>[new Text("${day.day}")];
      final scon = ScheduleContext.of(con);
      final todayScheds = scon.scheds
          .where((s) => s.dates.any((d) => Dates.isSameDay(d, day)))
          .toList();
      if (todayScheds.any((s) => scon.wl.any(
          (p) => s.playtimesForPlayer(p).any((d) => Dates.isSameDay(d, day)))))
        children.add(_watchlistEvent);
      else {
        if (todayScheds.isNotEmpty) {
          children.add(todayScheds.every((s) => s.hasFullRosters)
              ? _eventWithRoster
              : _eventNoRoster);
        }
      }
      return new Expanded(
          child: new TapNav(
              builder: (BuildContext _) => new DayPlanner(
                  scheds: todayScheds, watchlist: scon.wl, day: day),
              child: new Container(
                  decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.grey, width: 1.0)),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children))));
    } else {
      return new Expanded(child: new Container());
    }
  }
}

class WeekRow extends StatelessWidget {
  final DateTime month;
  final DateTime week;
  const WeekRow(this.month, this.week);

  build(BuildContext con) => new Expanded(
      child: new Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: range(7).map(
              (i) => new DaySquare(month, week.add(new Duration(days: i))))));
}

class WeekdayRow extends StatelessWidget {
  const WeekdayRow();

  build(BuildContext con) => new Row(
      children: Dates.weekdayAbbrevs
          .map((l) => new Expanded(
              child: new Center(
                  child: new Text(l,
                      style: const TextStyle(fontWeight: FontWeight.bold)))))
          .toList());
}

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime start;
  const MonthGrid(this.month, this.start);

  build(BuildContext con) => new Column(
      children: [const WeekdayRow()]..addAll(range(5).map(
              (i) => new WeekRow(month, start.add(new Duration(days: i * 7))))
          as List<WeekRow>));
}

class CalendarUIState extends State<CalendarUI> {
  DateTime month;
  List<TournamentSchedule> scheds = [];
  List<Player> watchlist = [];
  CalendarUIState(this.month);

  void loadSchedCon() async {
    final pc = new PlayerCache();
    final ss = await pc.getTournamentSchedules();
    final wl = await pc.getWatchlistPlayers();
    setState(() {
      scheds = ss.toList();
      watchlist = wl.toList();
    });
  }

  initState() {
    super.initState();
    loadSchedCon();
  }

  build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(Dates.formatMonth(month)), actions: [
        new IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              setState(() {
                month = Dates.prevMonth(month);
              });
            }),
        new IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              setState(() {
                month = Dates.nextMonth(month);
              });
            })
      ]),
      body: new ScheduleContext(
          scheds: scheds,
          wl: watchlist,
          child: new MonthGrid(month, Dates.monthStartDate(month))));
}

class ScheduleContext extends InheritedWidget {
  final List<TournamentSchedule> scheds;
  final List<Player> wl;
  ScheduleContext(
      {@required this.scheds, @required this.wl, key, @required child})
      : super(key: key, child: child);

  bool updateShouldNotify(ScheduleContext old) => old.scheds != scheds;

  static ScheduleContext of(BuildContext con) =>
      con.inheritFromWidgetOfExactType(ScheduleContext);
}
