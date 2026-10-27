import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

enum TransactionFormStatus {
  loading,
  ready,
  submitting,
  saved,
  deleted,
  loadFailed,
  failure,
}

class TransactionFormState extends Equatable {
  const TransactionFormState({
    this.status = TransactionFormStatus.loading,
    this.initial,
    this.failure,
  });

  final TransactionFormStatus status;

  /// The transaction being edited, or `null` when adding.
  final Transaction? initial;
  final Failure? failure;

  bool get isEditing => initial != null;

  TransactionFormState copyWith({
    TransactionFormStatus? status,
    Transaction? initial,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return TransactionFormState(
      status: status ?? this.status,
      initial: initial ?? this.initial,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, initial, failure];
}
