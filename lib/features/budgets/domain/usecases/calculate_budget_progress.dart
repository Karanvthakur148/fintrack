import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/entities/budget_progress.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Computes spending against each budget of the selected [month].
/// Only **expense** transactions of the budget's category that fall inside
/// that calendar month are counted. Results are sorted by usage, highest first.
class CalculateBudgetProgress {
  const CalculateBudgetProgress();

  List<BudgetProgress> call({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required DateTime month,
  }) {
    final key = AppDateUtils.monthKey(month);
    final from = AppDateUtils.startOfMonth(month);
    final to = AppDateUtils.endOfMonth(month);

    final spentByCategory = <String, int>{};
    for (final t in transactions) {
      if (t.isIncome) continue;
      if (!AppDateUtils.isInRange(t.date, from: from, to: to)) continue;
      spentByCategory.update(
        t.categoryId,
        (v) => v + t.amountMinor,
        ifAbsent: () => t.amountMinor,
      );
    }

    final result = budgets
        .where((b) => b.monthKey == key)
        .map(
          (b) => BudgetProgress(
            budget: b,
            spentMinor: spentByCategory[b.categoryId] ?? 0,
          ),
        )
        .toList();
    result.sort((a, b) => b.percentUsed.compareTo(a.percentUsed));
    return result;
  }
}
