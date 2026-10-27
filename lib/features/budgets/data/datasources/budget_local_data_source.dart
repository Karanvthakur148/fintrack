import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:hive/hive.dart';

abstract interface class BudgetLocalDataSource {
  Stream<List<BudgetModel>> watchAll();

  Future<List<BudgetModel>> getAll();

  Future<void> add(BudgetModel model);

  Future<void> update(BudgetModel model);

  Future<void> delete(String id);

  Future<void> upsert(BudgetModel model);

  Future<void> deleteIfExists(String id);

  Future<void> clear();
}

class HiveBudgetLocalDataSource implements BudgetLocalDataSource {
  HiveBudgetLocalDataSource(this._box);

  final Box<BudgetModel> _box;

  List<BudgetModel> _snapshot() => _box.values.toList(growable: false);

  @override
  Stream<List<BudgetModel>> watchAll() async* {
    yield _snapshot();
    yield* _box.watch().map((_) => _snapshot());
  }

  @override
  Future<List<BudgetModel>> getAll() async => _snapshot();

  @override
  Future<void> add(BudgetModel model) async {
    if (_box.containsKey(model.id)) {
      throw const CacheException('A budget with this id already exists.');
    }
    await _box.put(model.id, model);
  }

  @override
  Future<void> update(BudgetModel model) async {
    if (!_box.containsKey(model.id)) {
      throw const NotFoundException('Budget not found.');
    }
    await _box.put(model.id, model);
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Budget not found.');
    }
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<void> upsert(BudgetModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteIfExists(String id) async {
    if (_box.containsKey(id)) await _box.delete(id);
  }
}
