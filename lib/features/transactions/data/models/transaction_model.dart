import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// Hive representation of a [Transaction].
///
/// * `type` is stored as a string (`income` / `expense`) so enum reordering
///   can never corrupt stored data.
/// * `dateMs` encodes the *calendar day* as UTC midnight so the day never
///   shifts if the device time zone changes.
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.categoryId,
    required this.type,
    required this.dateMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.notes,
  });

  final String id;
  final String title;
  final int amountMinor;
  final String categoryId;
  final String type;
  final int dateMs;
  final String? notes;
  final int createdAtMs;
  final int updatedAtMs;

  static int encodeDay(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch;

  static DateTime decodeDay(int ms) {
    final utc = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    return DateTime(utc.year, utc.month, utc.day);
  }

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        title: t.title,
        amountMinor: t.amountMinor,
        categoryId: t.categoryId,
        type: t.type.name,
        dateMs: encodeDay(t.date),
        notes: t.notes,
        createdAtMs: t.createdAt.millisecondsSinceEpoch,
        updatedAtMs: t.updatedAt.millisecondsSinceEpoch,
      );

  Transaction toEntity() => Transaction(
        id: id,
        title: title,
        amountMinor: amountMinor,
        categoryId: categoryId,
        type: TransactionType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => TransactionType.expense,
        ),
        date: decodeDay(dateMs),
        notes: notes,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
      );
}
