import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

abstract final class BudgetValidator {
  static final RegExp _monthKey = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  static void validate(Budget budget) {
    if (budget.id.trim().isEmpty) {
      throw const ValidationException('Budget id is missing.');
    }
    final category = Categories.byId(budget.categoryId);
    if (category == null || category.type != TransactionType.expense) {
      throw const ValidationException('Choose an expense category.');
    }
    if (budget.limitMinor <= 0) {
      throw const ValidationException('Budget limit must be greater than zero.');
    }
    if (!_monthKey.hasMatch(budget.monthKey)) {
      throw const ValidationException('Invalid budget month.');
    }
  }
}
