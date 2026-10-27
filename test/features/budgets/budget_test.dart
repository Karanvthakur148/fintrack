import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/features/budgets/domain/entities/budget_progress.dart';
import 'package:fintrack/features/budgets/domain/usecases/calculate_budget_progress.dart';
import 'package:fintrack/features/budgets/domain/usecases/create_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/delete_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/update_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/watch_budgets.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

void main() {
  const calculate = CalculateBudgetProgress();

  group('BudgetProgress status', () {
    BudgetProgress p(int spent) => BudgetProgress(
          budget: buildBudget(limitMinor: 10000),
          spentMinor: spent,
        );

    test('on track below 80%', () {
      expect(p(7999).status, BudgetStatus.onTrack);
      expect(p(0).status, BudgetStatus.onTrack);
    });
    test('warning from 80% up to and including 100%', () {
      expect(p(8000).status, BudgetStatus.warning);
      expect(p(10000).status, BudgetStatus.warning);
      expect(p(10000).remainingMinor, 0);
    });
    test('exceeded above the limit', () {
      expect(p(10001).status, BudgetStatus.exceeded);
      expect(p(12500).overspentMinor, 2500);
      expect(p(12500).percentUsed, 1.25);
    });
  });

  group('CalculateBudgetProgress', () {
    test('counts only expenses of that category in the selected month', () {
      final result = calculate(
        budgets: [buildBudget(), buildBudget(id: 'b2', categoryId: 'transport', monthKey: '2024-04')],
        transactions: [
          buildTransaction(id: '1', amountMinor: 20000, date: DateTime(2024, 3, 1)),
          buildTransaction(id: '2', amountMinor: 5000, date: DateTime(2024, 3, 31)),
          buildTransaction(id: '3', amountMinor: 9999, date: DateTime(2024, 4, 1)),
          buildTransaction(id: '4', amountMinor: 9999, date: DateTime(2024, 2, 29)),
          buildTransaction(id: '5', amountMinor: 700, categoryId: 'transport', date: DateTime(2024, 3, 5)),
          buildIncome(date: DateTime(2024, 3, 3)),
        ],
        month: DateTime(2024, 3, 20),
      );
      expect(result.length, 1);
      expect(result.single.spentMinor, 25000);
      expect(result.single.remainingMinor, 75000);
    });

    test('no transactions means zero spent', () {
      final r = calculate(budgets: [buildBudget()], transactions: const [], month: DateTime(2024, 3));
      expect(r.single.spentMinor, 0);
      expect(r.single.status, BudgetStatus.onTrack);
    });

    test('sorted by usage, highest first', () {
      final r = calculate(
        budgets: [
          buildBudget(limitMinor: 100000),
          buildBudget(id: 'b2', categoryId: 'bills', limitMinor: 10000),
        ],
        transactions: [
          buildTransaction(id: '1', amountMinor: 1000),
          buildTransaction(id: '2', amountMinor: 9000, categoryId: 'bills'),
        ],
        month: DateTime(2024, 3),
      );
      expect(r.first.budget.categoryId, 'bills');
    });
  });

  group('Budget use cases', () {
    late BudgetRepositoryImpl repo;
    setUp(() => repo = BudgetRepositoryImpl(InMemoryBudgetDataSource()));

    test('create, update and delete', () async {
      await CreateBudget(repo)(buildBudget());
      await UpdateBudget(repo)(buildBudget(limitMinor: 55000));
      expect((await repo.getAll()).single.limitMinor, 55000);
      await DeleteBudget(repo)('b1');
      expect(await repo.getAll(), isEmpty);
    });

    test('one budget per category per month', () async {
      await CreateBudget(repo)(buildBudget());
      await expectLater(
        CreateBudget(repo)(buildBudget(id: 'other')),
        throwsA(isA<ValidationException>()),
      );
      // Same category in another month is fine.
      await CreateBudget(repo)(buildBudget(id: 'next', monthKey: '2024-04'));
      expect((await repo.getAll()).length, 2);
    });

    test('rejects invalid budgets', () async {
      final create = CreateBudget(repo);
      await expectLater(create(buildBudget(limitMinor: 0)), throwsA(isA<ValidationException>()));
      await expectLater(create(buildBudget(categoryId: 'salary')), throwsA(isA<ValidationException>()));
      await expectLater(create(buildBudget(monthKey: '2024-13')), throwsA(isA<ValidationException>()));
    });

    test('update/delete of unknown id throws NotFoundException', () async {
      await expectLater(UpdateBudget(repo)(buildBudget()), throwsA(isA<NotFoundException>()));
      await expectLater(DeleteBudget(repo)('ghost'), throwsA(isA<NotFoundException>()));
    });
  });

  test('BudgetsBloc combines budgets and transactions', () async {
    final budgetRepo = BudgetRepositoryImpl(InMemoryBudgetDataSource());
    final txRepo = TransactionRepositoryImpl(InMemoryTransactionDataSource());
    await txRepo.add(buildTransaction(amountMinor: 85000));

    final bloc = BudgetsBloc(
      watchBudgets: WatchBudgets(budgetRepo),
      watchTransactions: WatchTransactions(txRepo),
      createBudget: CreateBudget(budgetRepo),
      updateBudget: UpdateBudget(budgetRepo),
      deleteBudget: DeleteBudget(budgetRepo),
      calculateProgress: calculate,
      clock: () => DateTime(2024, 3, 15),
    )..add(const BudgetsStarted());

    await bloc.stream.firstWhere((s) => s.status == BudgetsStatus.success);
    await pumpEventQueue();

    final next = expectLater(
      bloc.stream,
      emitsThrough(
        predicate<BudgetsState>(
          (s) =>
              s.progress.length == 1 &&
              s.progress.single.spentMinor == 85000 &&
              s.progress.single.status == BudgetStatus.warning,
        ),
      ),
    );
    bloc.add(const BudgetCreateRequested(categoryId: 'food', limitMinor: 100000));
    await next;

    // Duplicate creation surfaces an error instead of throwing.
    final error = expectLater(
      bloc.stream,
      emitsThrough(predicate<BudgetsState>((s) => s.actionError != null)),
    );
    bloc.add(const BudgetCreateRequested(categoryId: 'food', limitMinor: 5000));
    await error;
    await bloc.close();
  });
}
