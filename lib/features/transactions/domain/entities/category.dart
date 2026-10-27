import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// A built-in transaction category with a stable string [id].
class Category extends Equatable {
  const Category({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final TransactionType type;

  @override
  List<Object?> get props => [id, name, type];
}

/// Registry of built-in categories. IDs are persisted; never rename them.
abstract final class Categories {
  static const Category food = Category(
    id: 'food',
    name: 'Food & Dining',
    type: TransactionType.expense,
  );
  static const Category transport = Category(
    id: 'transport',
    name: 'Transport',
    type: TransactionType.expense,
  );
  static const Category shopping = Category(
    id: 'shopping',
    name: 'Shopping',
    type: TransactionType.expense,
  );
  static const Category bills = Category(
    id: 'bills',
    name: 'Bills & Utilities',
    type: TransactionType.expense,
  );
  static const Category health = Category(
    id: 'health',
    name: 'Health',
    type: TransactionType.expense,
  );
  static const Category entertainment = Category(
    id: 'entertainment',
    name: 'Entertainment',
    type: TransactionType.expense,
  );
  static const Category education = Category(
    id: 'education',
    name: 'Education',
    type: TransactionType.expense,
  );
  static const Category otherExpense = Category(
    id: 'other_expense',
    name: 'Other',
    type: TransactionType.expense,
  );

  static const Category salary = Category(
    id: 'salary',
    name: 'Salary',
    type: TransactionType.income,
  );
  static const Category freelance = Category(
    id: 'freelance',
    name: 'Freelance',
    type: TransactionType.income,
  );
  static const Category investment = Category(
    id: 'investment',
    name: 'Investments',
    type: TransactionType.income,
  );
  static const Category otherIncome = Category(
    id: 'other_income',
    name: 'Other',
    type: TransactionType.income,
  );

  static const List<Category> expense = [
    food,
    transport,
    shopping,
    bills,
    health,
    entertainment,
    education,
    otherExpense,
  ];

  static const List<Category> income = [
    salary,
    freelance,
    investment,
    otherIncome,
  ];

  static const List<Category> all = [...expense, ...income];

  static List<Category> forType(TransactionType type) =>
      type.isIncome ? income : expense;

  /// Returns `null` for unknown ids.
  static Category? byId(String id) {
    for (final category in all) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Display name that never fails, even for unknown/legacy ids.
  static String nameOf(String id) => byId(id)?.name ?? 'Other';
}
