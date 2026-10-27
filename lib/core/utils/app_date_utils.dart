/// Date helpers. Named `AppDateUtils` to avoid clashing with Flutter's own
/// `DateUtils`. Pure Dart; safe to use from the domain layer.
abstract final class AppDateUtils {
  /// Midnight (00:00) of the same calendar day, in local time.
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Midnight of the **next** day. Use as an exclusive upper bound.
  static DateTime startOfNextDay(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1);

  /// True when [date] falls on or after the start day and on or before the
  /// end day (both days inclusive, any time of day).
  static bool isInRange(DateTime date, {DateTime? from, DateTime? to}) {
    if (from != null && date.isBefore(startOfDay(from))) return false;
    if (to != null && !date.isBefore(startOfNextDay(to))) return false;
    return true;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// Last calendar day of the month containing [date], at midnight.
  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  /// First instant of the following month (exclusive month upper bound).
  static DateTime startOfNextMonth(DateTime date) =>
      DateTime(date.year, date.month + 1);

  /// Number of days in [month] of [year], correct for leap years.
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Stable period identifier such as `2025-03`.
  static String monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';

  /// Monday of the week that contains [date], at midnight.
  static DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    return DateTime(day.year, day.month, day.day - (day.weekday - 1));
  }

  /// The seven days of the week containing [date], Monday first.
  static List<DateTime> daysOfWeek(DateTime date) {
    final monday = startOfWeek(date);
    return List<DateTime>.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }
}
