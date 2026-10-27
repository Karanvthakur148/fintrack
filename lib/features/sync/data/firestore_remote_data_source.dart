import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/features/sync/data/remote_change.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';

/// Firestore layout: `users/{uid}/{collection}/{id}`.
class FirestoreRemoteDataSource<T> implements RemoteDataSource<T> {
  FirestoreRemoteDataSource({
    required FirebaseFirestore firestore,
    required String collection,
    required Map<String, dynamic> Function(T model) toMap,
    required T? Function(String id, Map<String, dynamic> data) fromMap,
    required String Function(T model) idOf,
  })  : _db = firestore,
        _collection = collection,
        _toMap = toMap,
        _fromMap = fromMap,
        _idOf = idOf;

  final FirebaseFirestore _db;
  final String _collection;
  final Map<String, dynamic> Function(T model) _toMap;
  final T? Function(String id, Map<String, dynamic> data) _fromMap;
  final String Function(T model) _idOf;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection(_collection);

  @override
  Stream<List<RemoteChange<T>>> watch(String uid) {
    return _col(uid).snapshots().map((snapshot) {
      final changes = <RemoteChange<T>>[];
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          changes.add(RemoteChange<T>.removed(change.doc.id));
          continue;
        }
        final data = change.doc.data();
        final model = data == null ? null : _fromMap(change.doc.id, data);
        if (model != null) {
          changes.add(RemoteChange<T>.upsert(change.doc.id, model));
        }
      }
      return changes;
    });
  }

  @override
  Future<void> upsert(String uid, T model) =>
      _col(uid).doc(_idOf(model)).set(_toMap(model));

  @override
  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();

  @override
  Future<void> clear(String uid) async {
    final snapshot = await _col(uid).get();
    final docs = snapshot.docs;
    // Firestore batches are limited to 500 writes.
    for (var i = 0; i < docs.length; i += 400) {
      final batch = _db.batch();
      for (final doc in docs.skip(i).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
