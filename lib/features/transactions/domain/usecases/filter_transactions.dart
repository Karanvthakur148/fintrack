import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';

/// Pure search / filter / sort over an in-memory list.
class FilterTransactions {
  const FilterTransactions();

  List<Transaction> call(List<Transaction> input, TransactionFilter filter) {
    final query = filter.query.trim().toLowerCase();

    final result = input.where((t) {
      if (query.isNotEmpty && !t.title.toLowerCase().contains(query)) {
        return false;
      }
      if (filter.type != null && t.type != filter.type) return false;
      if (filter.categoryId != null && t.categoryId != filter.categoryId) {
        return false;
      }
      return AppDateUtils.isInRange(t.date, from: filter.from, to: filter.to);
    }).toList();

    result.sort((a, b) {
      var order = a.date.compareTo(b.date);
      if (order == 0) order = a.createdAt.compareTo(b.createdAt);
      return filter.sort == TransactionSort.newestFirst ? -order : order;
    });
    return result;
  }
}
