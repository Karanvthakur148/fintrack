import 'package:equatable/equatable.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = AppSettings.defaults,
    this.isClearing = false,
    this.message,
    this.messageIsError = false,
  });

  final AppSettings settings;
  final bool isClearing;

  /// One-shot feedback message for a snackbar.
  final String? message;
  final bool messageIsError;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isClearing,
    String? message,
    bool messageIsError = false,
    bool clearMessage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isClearing: isClearing ?? this.isClearing,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: clearMessage ? false : messageIsError,
    );
  }

  @override
  List<Object?> get props => [settings, isClearing, message, messageIsError];
}
