import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

final DateTime fixedCreatedAt = DateTime(2024);

Transaction buildTransaction({
  String id = 't1',
  String title = 'Lunch',
  int amountMinor = 10000,
  String categoryId = 'food',
  TransactionType type = TransactionType.expense,
  DateTime? date,
  String? notes,
}) {
  return Transaction(
    id: id,
    title: title,
    amountMinor: amountMinor,
    categoryId: categoryId,
    type: type,
    date: date ?? DateTime(2024, 3, 15),
    notes: notes,
    createdAt: fixedCreatedAt,
    updatedAt: fixedCreatedAt,
  );
}

Transaction buildIncome({
  String id = 'i1',
  int amountMinor = 500000,
  DateTime? date,
}) {
  return buildTransaction(
    id: id,
    title: 'Salary',
    amountMinor: amountMinor,
    categoryId: 'salary',
    type: TransactionType.income,
    date: date,
  );
}

Budget buildBudget({
  String id = 'b1',
  String categoryId = 'food',
  int limitMinor = 100000,
  String monthKey = '2024-03',
}) {
  return Budget(
    id: id,
    categoryId: categoryId,
    limitMinor: limitMinor,
    monthKey: monthKey,
  );
}
