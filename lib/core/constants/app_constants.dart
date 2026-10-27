/// App-wide constants that are not tied to a specific feature.
abstract final class AppConstants {
  static const String appName = 'FinTrack';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Offline-first personal finance tracker';

  // SharedPreferences keys (lightweight settings only).
  static const String prefThemeMode = 'settings.theme_mode';
  static const String prefCurrency = 'settings.currency';

  // Input limits.
  static const int maxTitleLength = 60;
  static const int maxNotesLength = 200;
}
