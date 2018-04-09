abstract class Dates {
  static String formatShort(DateTime d) => "${months[d.month - 1]} ${d.day}";

  static String formatLong(DateTime d) => d.toString();

  static String formatTime(DateTime d) => "${d.hour}:${d.minute}";

  static String formatMonth(DateTime m) => "${months[m.month - 1]} ${m.year}";

  static DateTime parsePGShort(String d, int year, int defaultMonth) {
    final match = new RegExp(r'^((...)\s+)?(\d\d?)$').firstMatch(d);
    final month = Dates.parseShortMonth(match[2]);
    return new DateTime(
        year, month > 0 ? month : defaultMonth, int.parse(match[3]));
  }

  static DateTime parsePGLong(String s) {
    final match = new RegExp(
            r'^\s*(\d?\d)/(\d?\d)/(\d\d\d\d)\s*(\d?\d):(\d\d)\s*(A|P)M\s*$')
        .firstMatch(s);
    final dt = new DateTime(
        int.parse(match[3]),
        int.parse(match[1]),
        int.parse(match[2]),
        (int.parse(match[4]) % 12) + (match[6] == 'A' ? 0 : 12),
        int.parse(match[5]));
    return dt;
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
