import 'package:equatable/equatable.dart';
import 'package:fintrack/features/auth/domain/entities/app_user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.isAvailable = false,
    this.busy = false,
    this.message,
    this.messageIsError = false,
  });

  /// `null` means guest (data stays on this device).
  final AppUser? user;

  /// Whether cloud services are configured.
  final bool isAvailable;
  final bool busy;
  final String? message;
  final bool messageIsError;

  bool get isSignedIn => user != null;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? busy,
    String? message,
    bool messageIsError = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAvailable: isAvailable,
      busy: busy ?? this.busy,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: clearMessage ? false : messageIsError,
    );
  }

  @override
  List<Object?> get props => [user, isAvailable, busy, message, messageIsError];
}
