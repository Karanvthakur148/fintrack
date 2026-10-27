import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

void main() {
  late TransactionRepositoryImpl repo;

  setUp(() => repo = TransactionRepositoryImpl(InMemoryTransactionDataSource()));

  test('starts empty', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add then getById round-trips every field', () async {
    final t = buildTransaction(notes: 'with friends');
    await repo.add(t);
    expect(await repo.getById('t1'), t);
  });

  test('getById throws NotFoundException for unknown id', () async {
    await expectLater(repo.getById('nope'), throwsA(isA<NotFoundException>()));
  });

  test('watchAll emits current data then every change', () async {
    final emissions = <int>[];
    final sub = repo.watchAll().listen((list) => emissions.add(list.length));
    await pumpEventQueue();

    await repo.add(buildTransaction());
    await pumpEventQueue();
    await repo.add(buildTransaction(id: 't2'));
    await pumpEventQueue();
    await repo.delete('t1');
    await pumpEventQueue();
    await repo.clear();
    await pumpEventQueue();

    expect(emissions, [0, 1, 2, 1, 0]);
    await sub.cancel();
  });

  test('model stores the calendar day independent of time of day', () {
    final model = TransactionModel.fromEntity(
      buildTransaction(date: DateTime(2024, 2, 29, 23, 59)),
    );
    expect(model.toEntity().date, DateTime(2024, 2, 29));
  });
}
