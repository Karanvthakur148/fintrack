import 'package:fintrack/features/auth/domain/entities/app_user.dart';

/// Account contract. Implementations throw `AuthException` with a
/// user-friendly message.
abstract interface class AuthRepository {
  /// False when cloud services are not configured (app runs local-only).
  bool get isAvailable;

  AppUser? get currentUser;

  /// Emits the current user (or `null`) immediately, then on every change.
  Stream<AppUser?> authChanges();

  Future<void> signIn(String email, String password);

  Future<void> signUp(String email, String password);

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}
