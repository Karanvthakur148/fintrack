import 'package:bloc_test/bloc_test.dart';
import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';
import 'package:fintrack/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_remote.dart';

void main() {
  late FakeAuthRepository repo;
  late List<String> order;

  AuthBloc makeBloc() => AuthBloc(
        watchAuthState: WatchAuthState(repo),
        signIn: SignIn(repo),
        signUp: SignUp(repo),
        signOut: SignOut(repo, () async => order.add('cleared')),
        sendPasswordReset: SendPasswordReset(repo),
        isAvailable: true,
      );

  setUp(() {
    repo = FakeAuthRepository();
    order = [];
  });

  group('use case validation', () {
    test('rejects bad email, empty password and weak sign-up password', () async {
      await expectLater(
        SignIn(repo)(email: 'nope', password: 'secret1'),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        SignIn(repo)(email: 'a@b.com', password: ''),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        SignUp(repo)(email: 'a@b.com', password: '123'),
        throwsA(isA<ValidationException>()),
      );
      expect(repo.calls, isEmpty);
    });

    test('valid input reaches the repository with a trimmed email', () async {
      await SignIn(repo)(email: ' a@b.com ', password: 'secret1');
      expect(repo.calls, ['signIn:a@b.com']);
    });
  });

  test('SignOut clears local data only after signing out', () async {
    repo.emitUser(const AppUser(uid: 'u1', email: 'a@b.com'));
    final signOut = SignOut(repo, () async {
      order.add('cleared while user=${repo.currentUser}');
    });
    await signOut();
    expect(order, ['cleared while user=null']);
  });

  blocTest<AuthBloc, AuthState>(
    'sign in success updates the user from the auth stream',
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AuthSignInRequested(email: 'a@b.com', password: 'secret1'));
    },
    verify: (bloc) {
      expect(bloc.state.user?.email, 'a@b.com');
      expect(bloc.state.busy, isFalse);
      expect(bloc.state.isSignedIn, isTrue);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'sign in failure shows an error message',
    build: makeBloc,
    setUp: () {
      repo.failNext = true;
    },
    act: (bloc) =>
        bloc.add(const AuthSignInRequested(email: 'a@b.com', password: 'secret1')),
    expect: () => [
      isA<AuthState>().having((s) => s.busy, 'busy', true),
      isA<AuthState>()
          .having((s) => s.busy, 'busy', false)
          .having((s) => s.messageIsError, 'error', true)
          .having((s) => s.message, 'message', 'Incorrect email or password.'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'validation errors never reach the repository',
    build: makeBloc,
    act: (bloc) =>
        bloc.add(const AuthSignUpRequested(email: 'bad', password: 'secret1')),
    verify: (bloc) {
      expect(repo.calls, isEmpty);
      expect(bloc.state.messageIsError, isTrue);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'sign out signs out and wipes local data',
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AuthSignInRequested(email: 'a@b.com', password: 'secret1'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AuthSignOutRequested());
    },
    verify: (bloc) {
      expect(bloc.state.user, isNull);
      expect(repo.calls, contains('signOut'));
      expect(order, ['cleared']);
    },
  );

  test('unavailable cloud keeps the bloc in guest mode', () {
    final bloc = AuthBloc(
      watchAuthState: WatchAuthState(FakeAuthRepository(available: false)),
      signIn: SignIn(repo),
      signUp: SignUp(repo),
      signOut: SignOut(repo, () async {}),
      sendPasswordReset: SendPasswordReset(repo),
      isAvailable: false,
    );
    expect(bloc.state.isAvailable, isFalse);
    expect(bloc.state.isSignedIn, isFalse);
    bloc.close();
  });
}
