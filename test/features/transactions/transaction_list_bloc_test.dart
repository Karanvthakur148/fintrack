import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/filter_transactions.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

void main() {
  late TransactionRepositoryImpl repo;
  late TransactionListBloc bloc;

  setUp(() {
    repo = TransactionRepositoryImpl(InMemoryTransactionDataSource());
    bloc = TransactionListBloc(
      watchTransactions: WatchTransactions(repo),
      deleteTransaction: DeleteTransaction(repo),
      filterTransactions: const FilterTransactions(),
    );
  });

  tearDown(() => bloc.close());

  Future<void> started() async {
    bloc.add(const TransactionListStarted());
    await bloc.stream.firstWhere((s) => s.status == TransactionListStatus.success);
    await pumpEventQueue();
  }

  test('loads existing transactions', () async {
    await repo.add(buildTransaction());
    bloc.add(const TransactionListStarted());
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<TransactionListState>(
          (s) => s.status == TransactionListStatus.success && s.all.length == 1,
        ),
      ),
    );
  });

  test('updates automatically when a transaction is added elsewhere', () async {
    await started();
    final next = expectLater(
      bloc.stream,
      emitsThrough(predicate<TransactionListState>((s) => s.all.length == 1)),
    );
    await repo.add(buildTransaction());
    await next;
  });

  test('search and type filter narrow the visible list', () async {
    await repo.add(buildTransaction(id: 'a', title: 'Coffee'));
    await repo.add(buildIncome());
    await started();

    bloc.add(const TransactionSearchChanged('cof'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<TransactionListState>((s) => s.visible.length == 1)),
    );

    bloc.add(const TransactionFiltersCleared());
    bloc.add(const TransactionTypeFilterChanged(TransactionType.income));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<TransactionListState>(
          (s) => s.visible.length == 1 && s.visible.single.isIncome,
        ),
      ),
    );
  });

  test('delete removes the item; deleting a missing id reports an error', () async {
    await repo.add(buildTransaction());
    await started();

    bloc.add(const TransactionDeleteRequested('t1'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<TransactionListState>((s) => s.all.isEmpty)),
    );

    bloc.add(const TransactionDeleteRequested('ghost'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<TransactionListState>((s) => s.actionError != null)),
    );
  });
}
