import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

enum TransactionSort { newestFirst, oldestFirst }

/// Immutable search / filter / sort criteria for the transaction list.
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.from,
    this.to,
    this.sort = TransactionSort.newestFirst,
  });

  final String query;
  final TransactionType? type;
  final String? categoryId;

  /// Inclusive start day.
  final DateTime? from;

  /// Inclusive end day.
  final DateTime? to;
  final TransactionSort sort;

  /// Number of non-search filters in use (for badges).
  int get activeFilterCount {
    var count = 0;
    if (type != null) count++;
    if (categoryId != null) count++;
    if (from != null || to != null) count++;
    if (sort != TransactionSort.newestFirst) count++;
    return count;
  }

  bool get isActive => query.trim().isNotEmpty || activeFilterCount > 0;

  TransactionFilter withQuery(String value) => TransactionFilter(
        query: value,
        type: type,
        categoryId: categoryId,
        from: from,
        to: to,
        sort: sort,
      );

  /// Changing the type drops a category that belongs to the other type.
  TransactionFilter withType(TransactionType? value) {
    final current = categoryId;
    var nextCategory = current;
    if (value != null &&
        current != null &&
        Categories.byId(current)?.type != value) {
      nextCategory = null;
    }
    return TransactionFilter(
      query: query,
      type: value,
      categoryId: nextCategory,
      from: from,
      to: to,
      sort: sort,
    );
  }

  TransactionFilter withCategory(String? value) => TransactionFilter(
        query: query,
        type: type,
        categoryId: value,
        from: from,
        to: to,
        sort: sort,
      );

  TransactionFilter withRange({DateTime? from, DateTime? to}) =>
      TransactionFilter(
        query: query,
        type: type,
        categoryId: categoryId,
        from: from,
        to: to,
        sort: sort,
      );

  TransactionFilter withSort(TransactionSort value) => TransactionFilter(
        query: query,
        type: type,
        categoryId: categoryId,
        from: from,
        to: to,
        sort: value,
      );

  @override
  List<Object?> get props => [query, type, categoryId, from, to, sort];
}
