import 'package:bloc_test/bloc_test.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/domain/usecases/add_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/get_transaction_by_id.dart';
import 'package:fintrack/features/transactions/domain/usecases/update_transaction.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

Matcher hasStatus(TransactionFormStatus status) =>
    isA<TransactionFormState>().having((s) => s.status, 'status', status);

void main() {
  late TransactionRepositoryImpl repo;

  TransactionFormBloc makeBloc() => TransactionFormBloc(
        addTransaction: AddTransaction(repo),
        updateTransaction: UpdateTransaction(repo),
        deleteTransaction: DeleteTransaction(repo),
        getTransactionById: GetTransactionById(repo),
      );

  final submit = TransactionFormSubmitted(
    title: 'Coffee',
    amountMinor: 25050,
    categoryId: 'food',
    type: TransactionType.expense,
    date: DateTime(2024, 3, 15),
    notes: '  ',
  );

  setUp(() => repo = TransactionRepositoryImpl(InMemoryTransactionDataSource()));

  blocTest<TransactionFormBloc, TransactionFormState>(
    'adds a new transaction',
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const TransactionFormStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(submit);
    },
    expect: () => [
      hasStatus(TransactionFormStatus.ready),
      hasStatus(TransactionFormStatus.submitting),
      hasStatus(TransactionFormStatus.saved),
    ],
    verify: (_) async {
      final stored = (await repo.getAll()).single;
      expect(stored.title, 'Coffee');
      expect(stored.amountMinor, 25050);
      expect(stored.notes, isNull);
    },
  );

  blocTest<TransactionFormBloc, TransactionFormState>(
    'reports validation errors without saving',
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const TransactionFormStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TransactionFormSubmitted(
        title: ' ',
        amountMinor: 100,
        categoryId: 'food',
        type: TransactionType.expense,
        date: DateTime(2024, 3, 15),
      ));
    },
    expect: () => [
      hasStatus(TransactionFormStatus.ready),
      hasStatus(TransactionFormStatus.submitting),
      isA<TransactionFormState>()
          .having((s) => s.status, 'status', TransactionFormStatus.failure)
          .having((s) => s.failure, 'failure', isNotNull),
    ],
    verify: (_) async => expect(await repo.getAll(), isEmpty),
  );

  blocTest<TransactionFormBloc, TransactionFormState>(
    'loads and edits an existing transaction',
    setUp: () async => repo.add(buildTransaction()),
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const TransactionFormStarted(transactionId: 't1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(submit);
    },
    expect: () => [
      isA<TransactionFormState>()
          .having((s) => s.status, 'status', TransactionFormStatus.ready)
          .having((s) => s.initial?.id, 'initial id', 't1'),
      hasStatus(TransactionFormStatus.submitting),
      hasStatus(TransactionFormStatus.saved),
    ],
    verify: (_) async {
      final stored = (await repo.getAll()).single;
      expect(stored.id, 't1');
      expect(stored.title, 'Coffee');
      expect(stored.createdAt, fixedCreatedAt);
    },
  );

  blocTest<TransactionFormBloc, TransactionFormState>(
    'missing id fails safely',
    build: makeBloc,
    act: (bloc) => bloc.add(const TransactionFormStarted(transactionId: 'ghost')),
    expect: () => [hasStatus(TransactionFormStatus.loadFailed)],
  );

  blocTest<TransactionFormBloc, TransactionFormState>(
    'deletes the edited transaction',
    setUp: () async => repo.add(buildTransaction()),
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const TransactionFormStarted(transactionId: 't1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const TransactionFormDeleteRequested());
    },
    expect: () => [
      hasStatus(TransactionFormStatus.ready),
      hasStatus(TransactionFormStatus.submitting),
      hasStatus(TransactionFormStatus.deleted),
    ],
    verify: (_) async => expect(await repo.getAll(), isEmpty),
  );
}
