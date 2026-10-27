import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Sums income and expense for an optional inclusive day range.
/// Income is never counted as expense and vice-versa.
class CalculateSummary {
  const CalculateSummary();

  FinancialSummary call(
    List<Transaction> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    var income = 0;
    var expense = 0;
    for (final t in transactions) {
      if (!AppDateUtils.isInRange(t.date, from: from, to: to)) continue;
      if (t.isIncome) {
        income += t.amountMinor;
      } else {
        expense += t.amountMinor;
      }
    }
    return FinancialSummary(incomeMinor: income, expenseMinor: expense);
  }
}
