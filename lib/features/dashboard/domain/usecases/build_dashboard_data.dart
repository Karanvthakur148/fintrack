import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_category_distribution.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_monthly_comparison.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_weekly_spending.dart';
import 'package:fintrack/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';
import 'package:fintrack/features/transactions/domain/usecases/calculate_summary.dart';
import 'package:fintrack/features/transactions/domain/usecases/filter_transactions.dart';

/// Composes the pure aggregation use cases into the dashboard view model.
class BuildDashboardData {
  const BuildDashboardData({
    this.calculateSummary = const CalculateSummary(),
    this.filterTransactions = const FilterTransactions(),
    this.categoryDistribution = const ComputeCategoryDistribution(),
    this.weeklySpending = const ComputeWeeklySpending(),
    this.monthlyComparison = const ComputeMonthlyComparison(),
    this.recentCount = 5,
  });

  final CalculateSummary calculateSummary;
  final FilterTransactions filterTransactions;
  final ComputeCategoryDistribution categoryDistribution;
  final ComputeWeeklySpending weeklySpending;
  final ComputeMonthlyComparison monthlyComparison;
  final int recentCount;

  DashboardData call(List<Transaction> transactions, DateTime now) {
    final monthStart = AppDateUtils.startOfMonth(now);
    final monthEnd = AppDateUtils.endOfMonth(now);

    return DashboardData(
      total: calculateSummary(transactions),
      month: calculateSummary(transactions, from: monthStart, to: monthEnd),
      recent: filterTransactions(transactions, const TransactionFilter())
          .take(recentCount)
          .toList(growable: false),
      monthCategories: categoryDistribution(
        transactions,
        from: monthStart,
        to: monthEnd,
      ),
      weekly: weeklySpending(transactions, now),
      monthly: monthlyComparison(transactions, now: now),
    );
  }
}
