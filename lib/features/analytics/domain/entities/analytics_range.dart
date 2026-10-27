import 'package:fintrack/core/utils/app_date_utils.dart';

/// Preset date ranges for the analytics screen.
enum AnalyticsRange {
  thisMonth('This month'),
  last30Days('30 days'),
  last3Months('3 months'),
  thisYear('This year'),
  allTime('All time');

  const AnalyticsRange(this.label);

  final String label;

  /// Inclusive start day, or `null` for no lower bound.
  DateTime? from(DateTime now) => switch (this) {
        AnalyticsRange.thisMonth => AppDateUtils.startOfMonth(now),
        AnalyticsRange.last30Days =>
          DateTime(now.year, now.month, now.day - 29),
        AnalyticsRange.last3Months => DateTime(now.year, now.month - 2),
        AnalyticsRange.thisYear => DateTime(now.year),
        AnalyticsRange.allTime => null,
      };

  /// Inclusive end day, or `null` for no upper bound.
  DateTime? to(DateTime now) => switch (this) {
        AnalyticsRange.thisMonth => AppDateUtils.endOfMonth(now),
        AnalyticsRange.last30Days => AppDateUtils.startOfDay(now),
        AnalyticsRange.last3Months => AppDateUtils.endOfMonth(now),
        AnalyticsRange.thisYear => DateTime(now.year, 12, 31),
        AnalyticsRange.allTime => null,
      };

  /// How many months the monthly comparison chart should show.
  int get monthsToShow =>
      (this == AnalyticsRange.thisYear || this == AnalyticsRange.allTime)
          ? 12
          : 6;
}
