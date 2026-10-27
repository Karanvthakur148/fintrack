import 'package:fintrack/features/budgets/domain/entities/budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchAll();

  Future<List<Budget>> getAll();

  Future<void> add(Budget budget);

  Future<void> update(Budget budget);

  Future<void> delete(String id);

  Future<void> clear();
}
