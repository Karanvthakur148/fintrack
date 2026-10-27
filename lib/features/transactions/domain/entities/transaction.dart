import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// A single income or expense. [amountMinor] is always positive and
/// expressed in minor units (paise/cents).
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.categoryId,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String title;
  final int amountMinor;
  final String categoryId;
  final TransactionType type;

  /// Calendar day of the transaction (local midnight).
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type.isIncome;

  Transaction copyWith({
    String? title,
    int? amountMinor,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amountMinor,
        categoryId,
        type,
        date,
        notes,
        createdAt,
        updatedAt,
      ];
}
