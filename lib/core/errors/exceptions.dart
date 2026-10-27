/// Thrown by the data layer / use cases. Mapped to Failures in BLoCs.
class CacheException implements Exception {
  const CacheException([this.message = 'Local storage operation failed.']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'The requested item was not found.']);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

/// Authentication / account problems (wrong password, no network, ...).
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
