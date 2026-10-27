import 'dart:async';

import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  /// See `TransactionRepositoryImpl` for the write-through behaviour.
  BudgetRepositoryImpl(
    this._source, {
    RemoteDataSource<BudgetModel>? remote,
    String? Function()? currentUid,
  })  : _remote = remote,
        _currentUid = currentUid;

  final BudgetLocalDataSource _source;
  final RemoteDataSource<BudgetModel>? _remote;
  final String? Function()? _currentUid;

  void _push(
    Future<void> Function(RemoteDataSource<BudgetModel> remote, String uid)
        action,
  ) {
    final remote = _remote;
    final uid = _currentUid?.call();
    if (remote == null || uid == null) return;
    unawaited(
      Future<void>.sync(() => action(remote, uid)).catchError((Object _) {}),
    );
  }

  static List<Budget> _toEntities(List<BudgetModel> models) =>
      models.map((m) => m.toEntity()).toList(growable: false);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on NotFoundException {
      rethrow;
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException('Storage error: $error');
    }
  }

  @override
  Stream<List<Budget>> watchAll() => _source.watchAll().map(_toEntities);

  @override
  Future<List<Budget>> getAll() =>
      _guard(() async => _toEntities(await _source.getAll()));

  @override
  Future<void> add(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    await _guard(() => _source.add(model));
    _push((remote, uid) => remote.upsert(uid, model));
  }

  @override
  Future<void> update(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    await _guard(() => _source.update(model));
    _push((remote, uid) => remote.upsert(uid, model));
  }

  @override
  Future<void> delete(String id) async {
    await _guard(() => _source.delete(id));
    _push((remote, uid) => remote.delete(uid, id));
  }

  @override
  Future<void> clear() async {
    await _guard(_source.clear);
    _push((remote, uid) => remote.clear(uid));
  }
}
