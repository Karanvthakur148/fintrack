import 'dart:async';

import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintrack/features/sync/data/remote_change.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';

/// Keeps one local collection in step with its cloud collection.
abstract interface class SyncTask {
  Future<void> start(String uid);

  Future<void> stop();
}

/// Pull side of the sync (cloud -> local). The push side (local -> cloud)
/// lives in the repositories, which write through to the cloud.
///
/// * Newest `updatedAt` wins.
/// * On the first snapshot, local items missing from (or newer than) the
///   cloud are uploaded, so offline / guest data is never lost on sign-in.
/// * Applying cloud changes bypasses the repositories, so nothing is pushed back.
class CollectionSync<T> implements SyncTask {
  CollectionSync({
    required this.localAll,
    required this.localUpsert,
    required this.localDelete,
    required this.remote,
    required this.idOf,
    required this.updatedAtOf,
  });

  final Future<List<T>> Function() localAll;
  final Future<void> Function(T model) localUpsert;
  final Future<void> Function(String id) localDelete;
  final RemoteDataSource<T> remote;
  final String Function(T model) idOf;
  final int Function(T model) updatedAtOf;

  StreamSubscription<void>? _subscription;

  @override
  Future<void> start(String uid) async {
    await stop();
    var first = true;
    _subscription = remote
        .watch(uid)
        .asyncMap((changes) async {
          final isFirst = first;
          first = false;
          await _apply(uid, changes, isFirst: isFirst);
        })
        .listen((_) {}, onError: (Object _) {});
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _apply(
    String uid,
    List<RemoteChange<T>> changes, {
    required bool isFirst,
  }) async {
    final local = <String, T>{
      for (final model in await localAll()) idOf(model): model,
    };
    final remoteModels = <String, T>{};

    for (final change in changes) {
      final model = change.model;
      if (change.removed || model == null) {
        await localDelete(change.id);
        local.remove(change.id);
        continue;
      }
      remoteModels[change.id] = model;
      final existing = local[change.id];
      if (existing == null || updatedAtOf(model) > updatedAtOf(existing)) {
        await localUpsert(model);
      }
    }

    if (isFirst) {
      for (final entry in local.entries) {
        final cloud = remoteModels[entry.key];
        if (cloud == null || updatedAtOf(entry.value) > updatedAtOf(cloud)) {
          unawaited(
            Future<void>.sync(() => remote.upsert(uid, entry.value))
                .catchError((Object _) {}),
          );
        }
      }
    }
  }
}

/// Starts and stops the [SyncTask]s as the user signs in and out.
class SyncCoordinator {
  SyncCoordinator({required AuthRepository auth, required List<SyncTask> tasks})
      : _auth = auth,
        _tasks = tasks;

  final AuthRepository _auth;
  final List<SyncTask> _tasks;
  StreamSubscription<AppUser?>? _subscription;
  String? _activeUid;

  void start() {
    _subscription ??= _auth.authChanges().listen(_onUser);
  }

  Future<void> _onUser(AppUser? user) async {
    if (user?.uid == _activeUid) return;
    for (final task in _tasks) {
      await task.stop();
    }
    _activeUid = user?.uid;
    if (user != null) {
      for (final task in _tasks) {
        await task.start(user.uid);
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    for (final task in _tasks) {
      await task.stop();
    }
  }
}
