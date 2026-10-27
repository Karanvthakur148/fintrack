import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/domain/usecases/add_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/update_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

void main() {
  late TransactionRepositoryImpl repo;
  late AddTransaction add;
  late UpdateTransaction update;
  late DeleteTransaction delete;
  final updatedAt = DateTime(2024, 6, 1);

  setUp(() {
    repo = TransactionRepositoryImpl(InMemoryTransactionDataSource());
    add = AddTransaction(repo);
    update = UpdateTransaction(repo, clock: () => updatedAt);
    delete = DeleteTransaction(repo);
  });

  group('AddTransaction', () {
    test('persists a valid transaction', () async {
      await add(buildTransaction());
      final all = await repo.getAll();
      expect(all.single.title, 'Lunch');
      expect(all.single.amountMinor, 10000);
    });

    test('rejects empty title, zero amount and mismatched category', () async {
      await expectLater(add(buildTransaction(title: '  ')), throwsA(isA<ValidationException>()));
      await expectLater(add(buildTransaction(amountMinor: 0)), throwsA(isA<ValidationException>()));
      await expectLater(add(buildTransaction(amountMinor: -5)), throwsA(isA<ValidationException>()));
      await expectLater(
        add(buildTransaction(categoryId: 'salary')),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        add(buildTransaction(categoryId: 'nope')),
        throwsA(isA<ValidationException>()),
      );
      expect(await repo.getAll(), isEmpty);
    });

    test('duplicate id is a CacheException', () async {
      await add(buildTransaction());
      await expectLater(add(buildTransaction()), throwsA(isA<CacheException>()));
    });
  });

  group('UpdateTransaction', () {
    test('updates fields, keeps createdAt, bumps updatedAt', () async {
      await add(buildTransaction());
      await update(buildTransaction(title: 'Dinner', amountMinor: 25000));
      final stored = (await repo.getAll()).single;
      expect(stored.title, 'Dinner');
      expect(stored.amountMinor, 25000);
      expect(stored.createdAt, fixedCreatedAt);
      expect(stored.updatedAt, updatedAt);
    });

    test('can change the type together with a matching category', () async {
      await add(buildTransaction());
      await update(buildTransaction(
        categoryId: 'salary',
        type: TransactionType.income,
      ));
      expect((await repo.getAll()).single.isIncome, isTrue);
    });

    test('missing id throws NotFoundException', () async {
      await expectLater(update(buildTransaction(id: 'ghost')), throwsA(isA<NotFoundException>()));
    });

    test('invalid data throws ValidationException', () async {
      await add(buildTransaction());
      await expectLater(update(buildTransaction(title: '')), throwsA(isA<ValidationException>()));
    });
  });

  group('DeleteTransaction', () {
    test('removes the transaction', () async {
      await add(buildTransaction());
      await delete('t1');
      expect(await repo.getAll(), isEmpty);
    });

    test('missing or blank id fails safely', () async {
      await expectLater(delete('ghost'), throwsA(isA<NotFoundException>()));
      await expectLater(delete(' '), throwsA(isA<ValidationException>()));
    });
  });
}
