import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';

class ClearBudgets {
  const ClearBudgets(this._repository);

  final BudgetRepository _repository;

  Future<void> call() => _repository.clear();
}
