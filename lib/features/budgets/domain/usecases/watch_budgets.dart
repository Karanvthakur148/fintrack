import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';

class WatchBudgets {
  const WatchBudgets(this._repository);

  final BudgetRepository _repository;

  Stream<List<Budget>> call() => _repository.watchAll();
}
