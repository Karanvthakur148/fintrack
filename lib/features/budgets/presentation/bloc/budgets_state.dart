import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/entities/budget_progress.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

enum BudgetsStatus { loading, success, failure }

class BudgetsState extends Equatable {
  const BudgetsState({
    required this.month,
    this.status = BudgetsStatus.loading,
    this.budgets = const [],
    this.transactions = const [],
    this.progress = const [],
    this.failure,
    this.actionError,
  });

  final BudgetsStatus status;

  /// First day of the selected month.
  final DateTime month;
  final List<Budget> budgets;
  final List<Transaction> transactions;

  /// Progress for budgets of [month] only.
  final List<BudgetProgress> progress;
  final Failure? failure;
  final String? actionError;

  int get totalLimitMinor =>
      progress.fold(0, (sum, p) => sum + p.budget.limitMinor);

  int get totalSpentMinor => progress.fold(0, (sum, p) => sum + p.spentMinor);

  int get exceededCount =>
      progress.where((p) => p.status == BudgetStatus.exceeded).length;

  int get warningCount =>
      progress.where((p) => p.status == BudgetStatus.warning).length;

  BudgetsState copyWith({
    BudgetsStatus? status,
    DateTime? month,
    List<Budget>? budgets,
    List<Transaction>? transactions,
    List<BudgetProgress>? progress,
    Failure? failure,
    String? actionError,
    bool clearActionError = false,
  }) {
    return BudgetsState(
      status: status ?? this.status,
      month: month ?? this.month,
      budgets: budgets ?? this.budgets,
      transactions: transactions ?? this.transactions,
      progress: progress ?? this.progress,
      failure: failure ?? this.failure,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        month,
        budgets,
        transactions,
        progress,
        failure,
        actionError,
      ];
}
