import 'package:equatable/equatable.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Everything the dashboard displays, derived from stored transactions.
class DashboardData extends Equatable {
  const DashboardData({
    required this.total,
    required this.month,
    required this.recent,
    required this.monthCategories,
    required this.weekly,
    required this.monthly,
  });

  /// All-time totals (balance = income - expense).
  final FinancialSummary total;

  /// Current calendar month totals.
  final FinancialSummary month;
  final List<Transaction> recent;

  /// Current month expense breakdown.
  final List<CategoryAmount> monthCategories;
  final List<DailyAmount> weekly;
  final List<MonthlyTotals> monthly;

  bool get hasTransactions => recent.isNotEmpty;

  @override
  List<Object?> get props =>
      [total, month, recent, monthCategories, weekly, monthly];
}
