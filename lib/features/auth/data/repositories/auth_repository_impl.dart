import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._source);

  final AuthRemoteDataSource _source;

  @override
  bool get isAvailable => true;

  @override
  AppUser? get currentUser => _source.currentUser;

  @override
  Stream<AppUser?> authChanges() => _source.authChanges();

  @override
  Future<void> signIn(String email, String password) =>
      _source.signIn(email, password);

  @override
  Future<void> signUp(String email, String password) =>
      _source.signUp(email, password);

  @override
  Future<void> signOut() => _source.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _source.sendPasswordReset(email);
}

/// Used when Firebase is not configured: the app stays fully usable offline.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  static const AuthException _error = AuthException(
    'Cloud sync is not set up. See FIREBASE_SETUP.md.',
  );

  @override
  bool get isAvailable => false;

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> authChanges() => Stream<AppUser?>.value(null);

  @override
  Future<void> signIn(String email, String password) => throw _error;

  @override
  Future<void> signUp(String email, String password) => throw _error;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) => throw _error;
}
