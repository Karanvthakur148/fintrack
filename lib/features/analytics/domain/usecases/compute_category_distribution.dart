import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/core/utils/money.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// Totals per category (largest first) for one transaction type and
/// optional inclusive day range.
class ComputeCategoryDistribution {
  const ComputeCategoryDistribution();

  List<CategoryAmount> call(
    List<Transaction> transactions, {
    DateTime? from,
    DateTime? to,
    TransactionType type = TransactionType.expense,
  }) {
    final totals = <String, int>{};
    var grandTotal = 0;
    for (final t in transactions) {
      if (t.type != type) continue;
      if (!AppDateUtils.isInRange(t.date, from: from, to: to)) continue;
      totals.update(
        t.categoryId,
        (value) => value + t.amountMinor,
        ifAbsent: () => t.amountMinor,
      );
      grandTotal += t.amountMinor;
    }

    final result = totals.entries
        .map(
          (e) => CategoryAmount(
            categoryId: e.key,
            amountMinor: e.value,
            share: Money.ratio(e.value, grandTotal),
          ),
        )
        .toList();
    result.sort((a, b) {
      final byAmount = b.amountMinor.compareTo(a.amountMinor);
      return byAmount != 0 ? byAmount : a.categoryId.compareTo(b.categoryId);
    });
    return result;
  }
}
