import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Income vs expense for the last [months] months ending at `now`'s month,
/// oldest first. Months without data are included with zero totals.
class ComputeMonthlyComparison {
  const ComputeMonthlyComparison();

  List<MonthlyTotals> call(
    List<Transaction> transactions, {
    required DateTime now,
    int months = 6,
  }) {
    final income = <String, int>{};
    final expense = <String, int>{};
    for (final t in transactions) {
      final key = AppDateUtils.monthKey(t.date);
      final target = t.isIncome ? income : expense;
      target.update(key, (v) => v + t.amountMinor, ifAbsent: () => t.amountMinor);
    }

    return [
      for (var i = months - 1; i >= 0; i--)
        () {
          final month = DateTime(now.year, now.month - i);
          final key = AppDateUtils.monthKey(month);
          return MonthlyTotals(
            month: month,
            incomeMinor: income[key] ?? 0,
            expenseMinor: expense[key] ?? 0,
          );
        }(),
    ];
  }
}
