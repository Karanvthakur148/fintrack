import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/calculate_budget_progress.dart';
import 'package:fintrack/features/budgets/domain/usecases/create_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/delete_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/update_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/watch_budgets.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:uuid/uuid.dart';

/// Combines the budgets stream and the shared transactions stream so that
/// budget progress always reflects the latest stored data.
class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  BudgetsBloc({
    required WatchBudgets watchBudgets,
    required WatchTransactions watchTransactions,
    required CreateBudget createBudget,
    required UpdateBudget updateBudget,
    required DeleteBudget deleteBudget,
    required CalculateBudgetProgress calculateProgress,
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  })  : _watchBudgets = watchBudgets,
        _watchTransactions = watchTransactions,
        _create = createBudget,
        _update = updateBudget,
        _delete = deleteBudget,
        _calculate = calculateProgress,
        _uuid = uuid,
        super(
          BudgetsState(
            month: AppDateUtils.startOfMonth((clock ?? DateTime.now)()),
          ),
        ) {
    on<BudgetsStarted>(_onStarted);
    on<BudgetsListUpdated>((e, emit) {
      _budgetsReady = true;
      emit(_recalculate(state.copyWith(budgets: e.budgets)));
    });
    on<BudgetsTransactionsUpdated>((e, emit) {
      _transactionsReady = true;
      emit(_recalculate(state.copyWith(transactions: e.transactions)));
    });
    on<BudgetsStreamFailed>(
      (e, emit) => emit(
        state.copyWith(status: BudgetsStatus.failure, failure: e.failure),
      ),
    );
    on<BudgetsMonthChanged>((e, emit) {
      final month = AppDateUtils.startOfMonth(e.month);
      emit(_recalculate(state.copyWith(month: month)));
    });
    on<BudgetCreateRequested>(_onCreate);
    on<BudgetUpdateRequested>(_onUpdate);
    on<BudgetDeleteRequested>(_onDeleteRequested);
    on<BudgetsErrorDismissed>(
      (e, emit) => emit(state.copyWith(clearActionError: true)),
    );
  }

  final WatchBudgets _watchBudgets;
  final WatchTransactions _watchTransactions;
  final CreateBudget _create;
  final UpdateBudget _update;
  final DeleteBudget _delete;
  final CalculateBudgetProgress _calculate;
  final Uuid _uuid;

  StreamSubscription<List<Budget>>? _budgetsSub;
  StreamSubscription<dynamic>? _transactionsSub;
  bool _budgetsReady = false;
  bool _transactionsReady = false;

  Future<void> _onStarted(
    BudgetsStarted event,
    Emitter<BudgetsState> emit,
  ) async {
    await _budgetsSub?.cancel();
    await _transactionsSub?.cancel();

    _budgetsSub = _watchBudgets().listen(
      (budgets) => add(BudgetsListUpdated(budgets)),
      onError: (Object error, StackTrace _) =>
          add(BudgetsStreamFailed(failureFrom(error))),
    );
    _transactionsSub = _watchTransactions().listen(
      (transactions) => add(BudgetsTransactionsUpdated(transactions)),
      onError: (Object error, StackTrace _) =>
          add(BudgetsStreamFailed(failureFrom(error))),
    );
  }

  BudgetsState _recalculate(BudgetsState s) {
    final progress = _calculate(
      budgets: s.budgets,
      transactions: s.transactions,
      month: s.month,
    );
    final ready = _budgetsReady && _transactionsReady;
    return s.copyWith(
      status: ready ? BudgetsStatus.success : s.status,
      progress: progress,
    );
  }

  Future<void> _onCreate(
    BudgetCreateRequested event,
    Emitter<BudgetsState> emit,
  ) async {
    try {
      await _create(
        Budget(
          id: _uuid.v4(),
          categoryId: event.categoryId,
          limitMinor: event.limitMinor,
          monthKey: AppDateUtils.monthKey(state.month),
        ),
      );
    } catch (error) {
      emit(state.copyWith(actionError: failureFrom(error).message));
    }
  }

  Future<void> _onUpdate(
    BudgetUpdateRequested event,
    Emitter<BudgetsState> emit,
  ) async {
    try {
      await _update(
        event.budget.copyWith(
          categoryId: event.categoryId,
          limitMinor: event.limitMinor,
        ),
      );
    } catch (error) {
      emit(state.copyWith(actionError: failureFrom(error).message));
    }
  }

  Future<void> _onDeleteRequested(
    BudgetDeleteRequested event,
    Emitter<BudgetsState> emit,
  ) async {
    try {
      await _delete(event.id);
    } catch (error) {
      emit(state.copyWith(actionError: failureFrom(error).message));
    }
  }

  @override
  Future<void> close() async {
    await _budgetsSub?.cancel();
    await _transactionsSub?.cancel();
    return super.close();
  }
}
