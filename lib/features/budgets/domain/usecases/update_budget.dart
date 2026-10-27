import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fintrack/features/budgets/domain/usecases/budget_validator.dart';

class UpdateBudget {
  const UpdateBudget(this._repository);

  final BudgetRepository _repository;

  Future<void> call(Budget budget) async {
    BudgetValidator.validate(budget);
    final existing = await _repository.getAll();
    if (!existing.any((b) => b.id == budget.id)) {
      throw const NotFoundException('Budget not found.');
    }
    final duplicate = existing.any(
      (b) =>
          b.id != budget.id &&
          b.categoryId == budget.categoryId &&
          b.monthKey == budget.monthKey,
    );
    if (duplicate) {
      throw const ValidationException(
        'A budget for this category already exists for this month.',
      );
    }
    await _repository.update(budget);
  }
}
