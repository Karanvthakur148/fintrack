import 'package:intl/intl.dart';

/// Shared date formats.
abstract final class AppFormats {
  static final DateFormat dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat dayMonth = DateFormat('d MMM');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  static final DateFormat monthShort = DateFormat('MMM');
  static final DateFormat weekdayShort = DateFormat('EEE');
}
