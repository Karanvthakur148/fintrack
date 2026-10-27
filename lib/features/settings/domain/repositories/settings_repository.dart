import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Never throws; falls back to [AppSettings.defaults].
  Future<AppSettings> load();

  Future<void> saveThemeMode(AppThemeMode mode);

  Future<void> saveCurrency(AppCurrency currency);
}
