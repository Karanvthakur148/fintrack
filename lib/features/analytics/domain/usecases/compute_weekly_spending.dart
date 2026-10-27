import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Expense totals for each of the seven days (Mon-Sun) of the week that
/// contains `anyDayInWeek`. Always returns exactly seven entries.
class ComputeWeeklySpending {
  const ComputeWeeklySpending();

  List<DailyAmount> call(List<Transaction> transactions, DateTime anyDayInWeek) {
    final days = AppDateUtils.daysOfWeek(anyDayInWeek);
    final totals = List<int>.filled(7, 0);

    for (final t in transactions) {
      if (t.isIncome) continue;
      final index = days.indexWhere((d) => AppDateUtils.isSameDay(d, t.date));
      if (index >= 0) totals[index] += t.amountMinor;
    }

    return [
      for (var i = 0; i < 7; i++)
        DailyAmount(date: days[i], amountMinor: totals[i]),
    ];
  }
}
