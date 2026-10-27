import 'package:fintrack/features/sync/data/remote_change.dart';

/// Cloud storage for one collection of models, scoped per user.
abstract interface class RemoteDataSource<T> {
  /// First event contains every document; later events only changes.
  Stream<List<RemoteChange<T>>> watch(String uid);

  Future<void> upsert(String uid, T model);

  Future<void> delete(String uid, String id);

  /// Deletes every document of the user's collection.
  Future<void> clear(String uid);
}
