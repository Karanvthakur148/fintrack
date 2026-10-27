import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudget {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Budget id is missing.');
    }
    await _repository.delete(id);
  }
}
