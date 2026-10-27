import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

sealed class TransactionListEvent extends Equatable {
  const TransactionListEvent();

  @override
  List<Object?> get props => const [];
}

final class TransactionListStarted extends TransactionListEvent {
  const TransactionListStarted();
}

final class TransactionSearchChanged extends TransactionListEvent {
  const TransactionSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class TransactionTypeFilterChanged extends TransactionListEvent {
  const TransactionTypeFilterChanged(this.type);

  final TransactionType? type;

  @override
  List<Object?> get props => [type];
}

final class TransactionCategoryFilterChanged extends TransactionListEvent {
  const TransactionCategoryFilterChanged(this.categoryId);

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class TransactionDateRangeChanged extends TransactionListEvent {
  const TransactionDateRangeChanged({this.from, this.to});

  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [from, to];
}

final class TransactionSortChanged extends TransactionListEvent {
  const TransactionSortChanged(this.sort);

  final TransactionSort sort;

  @override
  List<Object?> get props => [sort];
}

final class TransactionFiltersCleared extends TransactionListEvent {
  const TransactionFiltersCleared();
}

final class TransactionDeleteRequested extends TransactionListEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class TransactionListErrorDismissed extends TransactionListEvent {
  const TransactionListErrorDismissed();
}
