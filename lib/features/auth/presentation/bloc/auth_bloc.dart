import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required SendPasswordReset sendPasswordReset,
    required bool isAvailable,
    AppUser? initialUser,
  })  : _watch = watchAuthState,
        _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _reset = sendPasswordReset,
        super(AuthState(isAvailable: isAvailable, user: initialUser)) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(
      (e, emit) => _run(
        emit,
        () => _signIn(email: e.email, password: e.password),
      ),
    );
    on<AuthSignUpRequested>(
      (e, emit) => _run(
        emit,
        () => _signUp(email: e.email, password: e.password),
      ),
    );
    on<AuthSignOutRequested>(
      (e, emit) => _run(emit, _signOut.call, success: 'Signed out.'),
    );
    on<AuthPasswordResetRequested>(
      (e, emit) => _run(
        emit,
        () => _reset(e.email),
        success: 'Password reset email sent.',
      ),
    );
    on<AuthMessageDismissed>(
      (e, emit) => emit(state.copyWith(clearMessage: true)),
    );
  }

  final WatchAuthState _watch;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final SendPasswordReset _reset;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach<AppUser?>(
      _watch(),
      onData: (user) => state.copyWith(user: user, clearUser: user == null),
      onError: (error, _) => state.copyWith(
        message: failureFrom(error).message,
        messageIsError: true,
      ),
    );
  }

  Future<void> _run(
    Emitter<AuthState> emit,
    Future<void> Function() action, {
    String? success,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await action();
      emit(state.copyWith(busy: false, message: success));
    } catch (error) {
      emit(state.copyWith(
        busy: false,
        message: failureFrom(error).message,
        messageIsError: true,
      ));
    }
  }
}
