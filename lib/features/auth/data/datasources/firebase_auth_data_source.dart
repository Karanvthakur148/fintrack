import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRemoteDataSource {
  AppUser? get currentUser;

  Stream<AppUser?> authChanges();

  Future<void> signIn(String email, String password);

  Future<void> signUp(String email, String password);

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  static AppUser? _map(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email ?? '');

  static String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please try again when online.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled for this project.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_message(error.code));
    }
  }

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> authChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<void> signIn(String email, String password) => _guard(
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> signUp(String email, String password) => _guard(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));
}
