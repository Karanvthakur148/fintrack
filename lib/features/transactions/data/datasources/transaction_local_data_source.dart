import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:hive/hive.dart';

/// Storage contract. Faked in tests, implemented with Hive in production.
abstract interface class TransactionLocalDataSource {
  Stream<List<TransactionModel>> watchAll();

  Future<List<TransactionModel>> getAll();

  Future<TransactionModel?> getById(String id);

  /// Throws [CacheException] if the id already exists.
  Future<void> add(TransactionModel model);

  /// Throws [NotFoundException] if the id does not exist.
  Future<void> update(TransactionModel model);

  /// Throws [NotFoundException] if the id does not exist.
  Future<void> delete(String id);

  /// Insert or replace without checks (used when applying cloud changes).
  Future<void> upsert(TransactionModel model);

  /// Delete if present; never throws for a missing id.
  Future<void> deleteIfExists(String id);

  Future<void> clear();
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  HiveTransactionLocalDataSource(this._box);

  final Box<TransactionModel> _box;

  List<TransactionModel> _snapshot() => _box.values.toList(growable: false);

  @override
  Stream<List<TransactionModel>> watchAll() async* {
    yield _snapshot();
    yield* _box.watch().map((_) => _snapshot());
  }

  @override
  Future<List<TransactionModel>> getAll() async => _snapshot();

  @override
  Future<TransactionModel?> getById(String id) async => _box.get(id);

  @override
  Future<void> add(TransactionModel model) async {
    if (_box.containsKey(model.id)) {
      throw const CacheException('A transaction with this id already exists.');
    }
    await _box.put(model.id, model);
  }

  @override
  Future<void> update(TransactionModel model) async {
    if (!_box.containsKey(model.id)) {
      throw const NotFoundException('Transaction not found.');
    }
    await _box.put(model.id, model);
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Transaction not found.');
    }
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<void> upsert(TransactionModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteIfExists(String id) async {
    if (_box.containsKey(id)) await _box.delete(id);
  }
}
