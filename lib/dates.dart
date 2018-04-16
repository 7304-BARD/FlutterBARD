abstract class Dates {
  static String formatShort(DateTime d) =>
      "${months[d.month - 1]} ${d.day}, ${weekdayAbbrevs[d.weekday % 7]}";

  static String formatLong(DateTime d) =>
      [formatShort(d), formatTime(d)].join(' ');

  static String formatTime(DateTime d) =>
      "${d.hour}:${d.minute < 10 ? '0' : ''}${d.minute}";

  static String formatMonth(DateTime m) => "${months[m.month - 1]} ${m.year}";

  static DateTime parsePGShort(String d, int year, int defaultMonth) {
    final match = new RegExp(r'^((...)\s+)?(\d\d?)$').firstMatch(d);
    final month = Dates.parseShortMonth(match[2]);
    return new DateTime(
        year, month > 0 ? month : defaultMonth, int.parse(match[3]));
  }

  static DateTime parsePGMedium(String d) {
    final match = new RegExp(r'\s*(\d\d?)/(\d\d?)/(\d\d\d\d)\s*').firstMatch(d);
    return new DateTime(
        int.parse(match[3]), int.parse(match[1]), int.parse(match[2]));
  }

  static int _delocalizeHour(String hour, String ap) =>
      (int.parse(hour) % 12) + (ap == 'A' ? 0 : 12);

  static DateTime parsePGLong(String s) {
    final match = new RegExp(
            r'^\s*(\d?\d)/(\d?\d)/(\d\d\d\d)\s*(\d?\d):(\d\d)\s*(A|P)M\s*$')
        .firstMatch(s);
    return new DateTime(
        int.parse(match[3]),
        int.parse(match[1]),
        int.parse(match[2]),
        _delocalizeHour(match[4], match[6]),
        int.parse(match[5]));
  }

  static DateTime parsePGTime(DateTime day, String s) {
    final match = new RegExp(r'\s*^(\d?\d):(\d\d)\s*(A|P)M\s*$').firstMatch(s);
    return new DateTime(day.year, day.month, day.day,
        _delocalizeHour(match[1], match[3]), int.parse(match[2]));
  }

  static const monthAbbrevs = const [
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
  ];

  static const months = const [
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

  static const weekdayAbbrevs = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  static String getCurrentMonth() {
    final index = new DateTime.now().month - 1;
    return months[index];
  }

  static String getCurrentYear() => new DateTime.now().year.toString();

  static int parseShortMonth(String m) => monthAbbrevs.indexOf(m) + 1;
  static DateTime monthStartDate(DateTime m) => new DateTime(m.year, m.month);

  static DateTime prevMonth(DateTime m) => m.month == 1
      ? new DateTime(m.year - 1, 12)
      : new DateTime(m.year, m.month - 1);

  static DateTime nextMonth(DateTime m) => m.month == 12
      ? new DateTime(m.year + 1, 1)
      : new DateTime(m.year, m.month + 1);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
