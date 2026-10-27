import 'package:equatable/equatable.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_range.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => const [];
}

final class AnalyticsStarted extends AnalyticsEvent {
  const AnalyticsStarted();
}

final class AnalyticsRangeChanged extends AnalyticsEvent {
  const AnalyticsRangeChanged(this.range);

  final AnalyticsRange range;

  @override
  List<Object?> get props => [range];
}

/// Moves the weekly chart by [delta] weeks (negative = past). The week
/// offset never goes beyond the current week.
final class AnalyticsWeekShifted extends AnalyticsEvent {
  const AnalyticsWeekShifted(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}
