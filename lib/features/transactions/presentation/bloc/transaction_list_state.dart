import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';

enum TransactionListStatus { loading, success, failure }

class TransactionListState extends Equatable {
  const TransactionListState({
    this.status = TransactionListStatus.loading,
    this.all = const [],
    this.visible = const [],
    this.filter = const TransactionFilter(),
    this.failure,
    this.actionError,
  });

  final TransactionListStatus status;

  /// Every stored transaction.
  final List<Transaction> all;

  /// [all] after search / filter / sort.
  final List<Transaction> visible;
  final TransactionFilter filter;
  final Failure? failure;

  /// One-shot error from an action such as delete.
  final String? actionError;

  bool get hasAnyTransactions => all.isNotEmpty;

  TransactionListState copyWith({
    TransactionListStatus? status,
    List<Transaction>? all,
    List<Transaction>? visible,
    TransactionFilter? filter,
    Failure? failure,
    bool clearFailure = false,
    String? actionError,
    bool clearActionError = false,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      all: all ?? this.all,
      visible: visible ?? this.visible,
      filter: filter ?? this.filter,
      failure: clearFailure ? null : (failure ?? this.failure),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, all, visible, filter, failure, actionError];
}
