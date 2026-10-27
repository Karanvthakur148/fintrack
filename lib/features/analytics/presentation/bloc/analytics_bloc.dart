import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_category_distribution.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_monthly_comparison.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_weekly_spending.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/calculate_summary.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';

/// Keeps analytics in sync with the shared transaction stream and
/// recomputes charts when the range or visible week changes.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required WatchTransactions watchTransactions,
    required CalculateSummary calculateSummary,
    required ComputeCategoryDistribution computeCategoryDistribution,
    required ComputeWeeklySpending computeWeeklySpending,
    required ComputeMonthlyComparison computeMonthlyComparison,
    DateTime Function()? clock,
  })  : _watch = watchTransactions,
        _summary = calculateSummary,
        _distribution = computeCategoryDistribution,
        _weekly = computeWeeklySpending,
        _monthly = computeMonthlyComparison,
        _clock = clock ?? DateTime.now,
        super(const AnalyticsState()) {
    on<AnalyticsStarted>(_onStarted);
    on<AnalyticsRangeChanged>(
      (e, emit) => emit(_derive(state.copyWith(range: e.range))),
    );
    on<AnalyticsWeekShifted>((e, emit) {
      final offset = math.min(0, state.weekOffset + e.delta);
      emit(_derive(state.copyWith(weekOffset: offset)));
    });
  }

  final WatchTransactions _watch;
  final CalculateSummary _summary;
  final ComputeCategoryDistribution _distribution;
  final ComputeWeeklySpending _weekly;
  final ComputeMonthlyComparison _monthly;
  final DateTime Function() _clock;

  Future<void> _onStarted(
    AnalyticsStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    await emit.forEach<List<Transaction>>(
      _watch(),
      onData: (transactions) => _derive(
        state.copyWith(
          status: AnalyticsStatus.success,
          transactions: transactions,
        ),
      ),
      onError: (error, _) => state.copyWith(
        status: AnalyticsStatus.failure,
        failure: failureFrom(error),
      ),
    );
  }

  AnalyticsState _derive(AnalyticsState s) {
    final now = _clock();
    final from = s.range.from(now);
    final to = s.range.to(now);
    final weekAnchor = DateTime(now.year, now.month, now.day + 7 * s.weekOffset);

    return s.copyWith(
      summary: _summary(s.transactions, from: from, to: to),
      distribution: _distribution(s.transactions, from: from, to: to),
      weekStart: AppDateUtils.startOfWeek(weekAnchor),
      weekly: _weekly(s.transactions, weekAnchor),
      monthly: _monthly(
        s.transactions,
        now: now,
        months: s.range.monthsToShow,
      ),
    );
  }
}
