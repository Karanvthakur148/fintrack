import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/exceptions.dart';

/// Immutable error representation used in BLoC states.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local storage.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}

/// Converts any thrown object into a user-presentable [Failure].
Failure failureFrom(Object error) {
  if (error is Failure) return error;
  if (error is ValidationException) return ValidationFailure(error.message);
  if (error is NotFoundException) return NotFoundFailure(error.message);
  if (error is AuthException) return AuthFailure(error.message);
  if (error is CacheException) return CacheFailure(error.message);
  return const UnexpectedFailure();
}
