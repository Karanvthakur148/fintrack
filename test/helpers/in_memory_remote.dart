import 'dart:async';

import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/sync/data/remote_change.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';

/// Fake cloud collection. Calling [upsert] / [delete] from a test simulates
/// another device changing the data.
class InMemoryRemote<T> implements RemoteDataSource<T> {
  InMemoryRemote(this.idOf);

  final String Function(T model) idOf;
  final Map<String, Map<String, T>> store = {};
  final Map<String, StreamController<List<RemoteChange<T>>>> _controllers = {};

  Map<String, T> docs(String uid) => store.putIfAbsent(uid, () => {});

  StreamController<List<RemoteChange<T>>> _controller(String uid) =>
      _controllers.putIfAbsent(
        uid,
        () => StreamController<List<RemoteChange<T>>>.broadcast(),
      );

  @override
  Stream<List<RemoteChange<T>>> watch(String uid) async* {
    yield [
      for (final entry in docs(uid).entries)
        RemoteChange<T>.upsert(entry.key, entry.value),
    ];
    yield* _controller(uid).stream;
  }

  @override
  Future<void> upsert(String uid, T model) async {
    docs(uid)[idOf(model)] = model;
    _controller(uid).add([RemoteChange<T>.upsert(idOf(model), model)]);
  }

  @override
  Future<void> delete(String uid, String id) async {
    if (docs(uid).remove(id) != null) {
      _controller(uid).add([RemoteChange<T>.removed(id)]);
    }
  }

  @override
  Future<void> clear(String uid) async {
    final ids = docs(uid).keys.toList();
    docs(uid).clear();
    _controller(uid).add([for (final id in ids) RemoteChange<T>.removed(id)]);
  }
}

/// Controllable [AuthRepository] for tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.available = true});

  final bool available;
  AppUser? _user;
  final StreamController<AppUser?> _changes =
      StreamController<AppUser?>.broadcast();
  final List<String> calls = [];
  bool failNext = false;

  void _set(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  void emitUser(AppUser? user) => _set(user);

  @override
  bool get isAvailable => available;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw const AuthException('Incorrect email or password.');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    calls.add('signIn:$email');
    _maybeFail();
    _set(AppUser(uid: 'u1', email: email));
  }

  @override
  Future<void> signUp(String email, String password) async {
    calls.add('signUp:$email');
    _maybeFail();
    _set(AppUser(uid: 'u1', email: email));
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _set(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    calls.add('reset:$email');
    _maybeFail();
  }
}
