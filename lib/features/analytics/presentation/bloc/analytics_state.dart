import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_range.dart';
import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

enum AnalyticsStatus { loading, success, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.loading,
    this.range = AnalyticsRange.thisMonth,
    this.weekOffset = 0,
    this.transactions = const [],
    this.summary = FinancialSummary.empty,
    this.distribution = const [],
    this.weekStart,
    this.weekly = const [],
    this.monthly = const [],
    this.failure,
  });

  final AnalyticsStatus status;
  final AnalyticsRange range;

  /// 0 = current week, -1 = last week, ...
  final int weekOffset;
  final List<Transaction> transactions;
  final FinancialSummary summary;
  final List<CategoryAmount> distribution;
  final DateTime? weekStart;
  final List<DailyAmount> weekly;
  final List<MonthlyTotals> monthly;
  final Failure? failure;

  bool get hasTransactions => transactions.isNotEmpty;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsRange? range,
    int? weekOffset,
    List<Transaction>? transactions,
    FinancialSummary? summary,
    List<CategoryAmount>? distribution,
    DateTime? weekStart,
    List<DailyAmount>? weekly,
    List<MonthlyTotals>? monthly,
    Failure? failure,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      range: range ?? this.range,
      weekOffset: weekOffset ?? this.weekOffset,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      distribution: distribution ?? this.distribution,
      weekStart: weekStart ?? this.weekStart,
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        range,
        weekOffset,
        transactions,
        summary,
        distribution,
        weekStart,
        weekly,
        monthly,
        failure,
      ];
}
