import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

sealed class BudgetsEvent extends Equatable {
  const BudgetsEvent();

  @override
  List<Object?> get props => const [];
}

final class BudgetsStarted extends BudgetsEvent {
  const BudgetsStarted();
}

final class BudgetsMonthChanged extends BudgetsEvent {
  const BudgetsMonthChanged(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}

/// Creates a budget in the currently selected month.
final class BudgetCreateRequested extends BudgetsEvent {
  const BudgetCreateRequested({
    required this.categoryId,
    required this.limitMinor,
  });

  final String categoryId;
  final int limitMinor;

  @override
  List<Object?> get props => [categoryId, limitMinor];
}

final class BudgetUpdateRequested extends BudgetsEvent {
  const BudgetUpdateRequested({
    required this.budget,
    required this.categoryId,
    required this.limitMinor,
  });

  final Budget budget;
  final String categoryId;
  final int limitMinor;

  @override
  List<Object?> get props => [budget, categoryId, limitMinor];
}

final class BudgetDeleteRequested extends BudgetsEvent {
  const BudgetDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class BudgetsErrorDismissed extends BudgetsEvent {
  const BudgetsErrorDismissed();
}

/// Internal: the budgets stream emitted.
final class BudgetsListUpdated extends BudgetsEvent {
  const BudgetsListUpdated(this.budgets);

  final List<Budget> budgets;

  @override
  List<Object?> get props => [budgets];
}

/// Internal: the transactions stream emitted.
final class BudgetsTransactionsUpdated extends BudgetsEvent {
  const BudgetsTransactionsUpdated(this.transactions);

  final List<Transaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

/// Internal: one of the streams failed.
final class BudgetsStreamFailed extends BudgetsEvent {
  const BudgetsStreamFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
