import 'dart:async';

import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:fintrack/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';

/// Behaves like the Hive data source but keeps everything in memory.
class InMemoryTransactionDataSource implements TransactionLocalDataSource {
  final Map<String, TransactionModel> _store = {};
  final StreamController<List<TransactionModel>> _changes =
      StreamController<List<TransactionModel>>.broadcast();

  List<TransactionModel> _snapshot() => _store.values.toList(growable: false);

  void _notify() => _changes.add(_snapshot());

  @override
  Stream<List<TransactionModel>> watchAll() async* {
    yield _snapshot();
    yield* _changes.stream;
  }

  @override
  Future<List<TransactionModel>> getAll() async => _snapshot();

  @override
  Future<TransactionModel?> getById(String id) async => _store[id];

  @override
  Future<void> add(TransactionModel model) async {
    if (_store.containsKey(model.id)) {
      throw const CacheException('A transaction with this id already exists.');
    }
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> update(TransactionModel model) async {
    if (!_store.containsKey(model.id)) {
      throw const NotFoundException('Transaction not found.');
    }
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    if (_store.remove(id) == null) {
      throw const NotFoundException('Transaction not found.');
    }
    _notify();
  }

  @override
  Future<void> upsert(TransactionModel model) async {
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> deleteIfExists(String id) async {
    if (_store.remove(id) != null) _notify();
  }

  @override
  Future<void> clear() async {
    _store.clear();
    _notify();
  }
}

class InMemoryBudgetDataSource implements BudgetLocalDataSource {
  final Map<String, BudgetModel> _store = {};
  final StreamController<List<BudgetModel>> _changes =
      StreamController<List<BudgetModel>>.broadcast();

  List<BudgetModel> _snapshot() => _store.values.toList(growable: false);

  void _notify() => _changes.add(_snapshot());

  @override
  Stream<List<BudgetModel>> watchAll() async* {
    yield _snapshot();
    yield* _changes.stream;
  }

  @override
  Future<List<BudgetModel>> getAll() async => _snapshot();

  @override
  Future<void> add(BudgetModel model) async {
    if (_store.containsKey(model.id)) {
      throw const CacheException('A budget with this id already exists.');
    }
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> update(BudgetModel model) async {
    if (!_store.containsKey(model.id)) {
      throw const NotFoundException('Budget not found.');
    }
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    if (_store.remove(id) == null) {
      throw const NotFoundException('Budget not found.');
    }
    _notify();
  }

  @override
  Future<void> clear() async {
    _store.clear();
    _notify();
  }

  @override
  Future<void> upsert(BudgetModel model) async {
    _store[model.id] = model;
    _notify();
  }

  @override
  Future<void> deleteIfExists(String id) async {
    if (_store.remove(id) != null) _notify();
  }
}
