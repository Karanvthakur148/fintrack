import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.authChanges();
}

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) async {
    final emailError = Validators.email(email);
    if (emailError != null) throw ValidationException(emailError);
    if (password.isEmpty) {
      throw const ValidationException('Please enter your password');
    }
    await _repository.signIn(email.trim(), password);
  }
}

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) async {
    final emailError = Validators.email(email);
    if (emailError != null) throw ValidationException(emailError);
    final passwordError = Validators.password(password);
    if (passwordError != null) throw ValidationException(passwordError);
    await _repository.signUp(email.trim(), password);
  }
}

class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) async {
    final emailError = Validators.email(email);
    if (emailError != null) throw ValidationException(emailError);
    await _repository.sendPasswordReset(email.trim());
  }
}

/// Signs out, then wipes the data stored on this device so the next person
/// using the phone never sees (or uploads) it. The data stays in the account
/// and comes back after the next sign-in.
class SignOut {
  const SignOut(this._repository, this._clearLocalData);

  final AuthRepository _repository;
  final Future<void> Function() _clearLocalData;

  Future<void> call() async {
    await _repository.signOut();
    // The user is already signed out here, so this clears only local data.
    await _clearLocalData();
  }
}
