import 'dart:async';

import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';
import 'package:fintrack/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  /// Hive is always the source of truth for the UI. When [remote] is given
  /// and a user is signed in ([currentUid] returns non-null), every write is
  /// also pushed to the cloud without blocking (Firestore queues it offline).
  TransactionRepositoryImpl(
    this._source, {
    RemoteDataSource<TransactionModel>? remote,
    String? Function()? currentUid,
  })  : _remote = remote,
        _currentUid = currentUid;

  final TransactionLocalDataSource _source;
  final RemoteDataSource<TransactionModel>? _remote;
  final String? Function()? _currentUid;

  void _push(
    Future<void> Function(RemoteDataSource<TransactionModel> remote, String uid)
        action,
  ) {
    final remote = _remote;
    final uid = _currentUid?.call();
    if (remote == null || uid == null) return;
    unawaited(
      Future<void>.sync(() => action(remote, uid)).catchError((Object _) {}),
    );
  }

  static List<Transaction> _toEntities(List<TransactionModel> models) =>
      models.map((m) => m.toEntity()).toList(growable: false);

  /// Converts unexpected storage errors into [CacheException].
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
  Stream<List<Transaction>> watchAll() => _source.watchAll().map(_toEntities);

  @override
  Future<List<Transaction>> getAll() =>
      _guard(() async => _toEntities(await _source.getAll()));

  @override
  Future<Transaction> getById(String id) => _guard(() async {
        final model = await _source.getById(id);
        if (model == null) {
          throw const NotFoundException('Transaction not found.');
        }
        return model.toEntity();
      });

  @override
  Future<void> add(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _guard(() => _source.add(model));
    _push((remote, uid) => remote.upsert(uid, model));
  }

  @override
  Future<void> update(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
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
