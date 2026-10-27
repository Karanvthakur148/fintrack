import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

sealed class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();

  @override
  List<Object?> get props => const [];
}

/// Opens the form. With a [transactionId] the transaction is loaded for
/// editing; without one the form is ready for a new entry.
final class TransactionFormStarted extends TransactionFormEvent {
  const TransactionFormStarted({this.transactionId});

  final String? transactionId;

  @override
  List<Object?> get props => [transactionId];
}

final class TransactionFormSubmitted extends TransactionFormEvent {
  const TransactionFormSubmitted({
    required this.title,
    required this.amountMinor,
    required this.categoryId,
    required this.type,
    required this.date,
    this.notes,
  });

  final String title;
  final int amountMinor;
  final String categoryId;
  final TransactionType type;
  final DateTime date;
  final String? notes;

  @override
  List<Object?> get props =>
      [title, amountMinor, categoryId, type, date, notes];
}

final class TransactionFormDeleteRequested extends TransactionFormEvent {
  const TransactionFormDeleteRequested();
}
