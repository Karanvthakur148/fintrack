import 'package:equatable/equatable.dart';
import 'package:fintrack/core/constants/app_currency.dart';

/// Pure-Dart theme preference (mapped to Flutter's ThemeMode in the UI).
enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromName(String? name) {
    for (final mode in AppThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return AppThemeMode.system;
  }
}

class AppSettings extends Equatable {
  const AppSettings({required this.themeMode, required this.currency});

  static const AppSettings defaults = AppSettings(
    themeMode: AppThemeMode.system,
    currency: AppCurrency.inr,
  );

  final AppThemeMode themeMode;
  final AppCurrency currency;

  AppSettings copyWith({AppThemeMode? themeMode, AppCurrency? currency}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        currency: currency ?? this.currency,
      );

  @override
  List<Object?> get props => [themeMode, currency];
}
