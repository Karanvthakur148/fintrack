import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:fintrack/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/features/sync/data/firestore_mappers.dart';
import 'package:fintrack/features/sync/data/sync_coordinator.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';
import '../../helpers/in_memory_remote.dart';

TransactionModel model(String id, {int updatedMs = 1000, String title = 'Item'}) {
  return TransactionModel.fromEntity(
    buildTransaction(id: id, title: title).copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedMs),
    ),
  );
}

void main() {
  group('repository write-through', () {
    late InMemoryTransactionDataSource local;
    late InMemoryRemote<TransactionModel> remote;
    String? uid;
    late TransactionRepositoryImpl repo;

    setUp(() {
      local = InMemoryTransactionDataSource();
      remote = InMemoryRemote<TransactionModel>((m) => m.id);
      uid = 'u1';
      repo = TransactionRepositoryImpl(local, remote: remote, currentUid: () => uid);
    });

    test('add, update, delete and clear are pushed when signed in', () async {
      await repo.add(buildTransaction());
      await pumpEventQueue();
      expect(remote.docs('u1').keys, ['t1']);

      await repo.update(buildTransaction(title: 'Renamed'));
      await pumpEventQueue();
      expect(remote.docs('u1')['t1']!.title, 'Renamed');

      await repo.delete('t1');
      await pumpEventQueue();
      expect(remote.docs('u1'), isEmpty);

      await repo.add(buildTransaction(id: 'a'));
      await repo.add(buildTransaction(id: 'b'));
      await repo.clear();
      await pumpEventQueue();
      expect(remote.docs('u1'), isEmpty);
      expect(await repo.getAll(), isEmpty);
    });

    test('nothing is pushed for guests, local data is still saved', () async {
      uid = null;
      await repo.add(buildTransaction());
      await pumpEventQueue();
      expect(remote.docs('u1'), isEmpty);
      expect((await repo.getAll()).length, 1);
    });

    test('a failing cloud never breaks local writes', () async {
      final broken = _BrokenRemote();
      final r = TransactionRepositoryImpl(local, remote: broken, currentUid: () => 'u1');
      await r.add(buildTransaction());
      await pumpEventQueue();
      expect((await r.getAll()).length, 1);
    });

    test('budgets are pushed too', () async {
      final budgetRemote = InMemoryRemote<BudgetModel>((m) => m.id);
      final budgets = BudgetRepositoryImpl(
        InMemoryBudgetDataSource(),
        remote: budgetRemote,
        currentUid: () => 'u1',
      );
      await budgets.add(buildBudget());
      await pumpEventQueue();
      expect(budgetRemote.docs('u1').keys, ['b1']);
      await budgets.delete('b1');
      await pumpEventQueue();
      expect(budgetRemote.docs('u1'), isEmpty);
    });
  });

  group('CollectionSync (cloud -> local)', () {
    late InMemoryTransactionDataSource local;
    late InMemoryRemote<TransactionModel> remote;
    late CollectionSync<TransactionModel> sync;

    setUp(() {
      local = InMemoryTransactionDataSource();
      remote = InMemoryRemote<TransactionModel>((m) => m.id);
      sync = CollectionSync<TransactionModel>(
        localAll: local.getAll,
        localUpsert: local.upsert,
        localDelete: local.deleteIfExists,
        remote: remote,
        idOf: (m) => m.id,
        updatedAtOf: (m) => m.updatedAtMs,
      );
    });

    tearDown(() => sync.stop());

    test('cloud data is downloaded on start', () async {
      await remote.upsert('u1', model('a'));
      await sync.start('u1');
      await pumpEventQueue();
      expect((await local.getAll()).map((m) => m.id), ['a']);
    });

    test('local-only data is uploaded on first sync (nothing is lost)', () async {
      await local.upsert(model('guest'));
      await sync.start('u1');
      await pumpEventQueue();
      expect(remote.docs('u1').keys, ['guest']);
    });

    test('newest updatedAt wins in both directions', () async {
      await local.upsert(model('x', updatedMs: 5000, title: 'local new'));
      await local.upsert(model('y', updatedMs: 1000, title: 'local old'));
      await remote.upsert('u1', model('x', updatedMs: 2000, title: 'cloud old'));
      await remote.upsert('u1', model('y', updatedMs: 9000, title: 'cloud new'));

      await sync.start('u1');
      await pumpEventQueue();

      final byId = {for (final m in await local.getAll()) m.id: m};
      expect(byId['x']!.title, 'local new');
      expect(byId['y']!.title, 'cloud new');
      expect(remote.docs('u1')['x']!.title, 'local new');
    });

    test('changes from another device arrive live', () async {
      await sync.start('u1');
      await pumpEventQueue();

      await remote.upsert('u1', model('n', title: 'from phone 2'));
      await pumpEventQueue();
      expect((await local.getAll()).single.title, 'from phone 2');

      await remote.upsert('u1', model('n', updatedMs: 4000, title: 'edited'));
      await pumpEventQueue();
      expect((await local.getAll()).single.title, 'edited');

      await remote.delete('u1', 'n');
      await pumpEventQueue();
      expect(await local.getAll(), isEmpty);
    });
  });

  group('SyncCoordinator', () {
    test('starts on sign-in and stops on sign-out', () async {
      final auth = FakeAuthRepository();
      final local = InMemoryTransactionDataSource();
      final remote = InMemoryRemote<TransactionModel>((m) => m.id);
      final coordinator = SyncCoordinator(
        auth: auth,
        tasks: [
          CollectionSync<TransactionModel>(
            localAll: local.getAll,
            localUpsert: local.upsert,
            localDelete: local.deleteIfExists,
            remote: remote,
            idOf: (m) => m.id,
            updatedAtOf: (m) => m.updatedAtMs,
          ),
        ],
      )..start();
      await pumpEventQueue();

      // Guest: remote changes are ignored.
      await remote.upsert('u1', model('before'));
      await pumpEventQueue();
      expect(await local.getAll(), isEmpty);

      auth.emitUser(const AppUser(uid: 'u1', email: 'a@b.com'));
      await pumpEventQueue();
      expect((await local.getAll()).map((m) => m.id), ['before']);

      auth.emitUser(null);
      await pumpEventQueue();
      await remote.upsert('u1', model('after'));
      await pumpEventQueue();
      expect((await local.getAll()).map((m) => m.id), ['before']);

      await coordinator.dispose();
    });
  });

  group('FirestoreMappers', () {
    test('transaction round-trips', () {
      final m = TransactionModel.fromEntity(buildTransaction(notes: 'hi'));
      final back = FirestoreMappers.transactionFromMap(
        m.id,
        FirestoreMappers.transactionToMap(m),
      )!;
      expect(back.title, m.title);
      expect(back.amountMinor, m.amountMinor);
      expect(back.dateMs, m.dateMs);
      expect(back.notes, 'hi');
    });

    test('budget round-trips and invalid documents are ignored', () {
      final b = BudgetModel.fromEntity(buildBudget());
      final back = FirestoreMappers.budgetFromMap(
        b.id,
        FirestoreMappers.budgetToMap(b),
      )!;
      expect(back.limitMinor, b.limitMinor);
      expect(back.monthKey, b.monthKey);

      expect(FirestoreMappers.transactionFromMap('x', {'title': 5}), isNull);
      expect(FirestoreMappers.budgetFromMap('x', {}), isNull);
    });
  });
}

class _BrokenRemote extends InMemoryRemote<TransactionModel> {
  _BrokenRemote() : super((m) => m.id);

  @override
  Future<void> upsert(String uid, TransactionModel model) =>
      throw StateError('offline');
}
