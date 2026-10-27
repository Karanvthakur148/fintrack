import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._source);

  final SettingsLocalDataSource _source;

  @override
  Future<AppSettings> load() async {
    try {
      return AppSettings(
        themeMode: AppThemeMode.fromName(
          _source.getString(AppConstants.prefThemeMode),
        ),
        currency: AppCurrency.fromCode(
          _source.getString(AppConstants.prefCurrency),
        ),
      );
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) =>
      _source.setString(AppConstants.prefThemeMode, mode.name);

  @override
  Future<void> saveCurrency(AppCurrency currency) =>
      _source.setString(AppConstants.prefCurrency, currency.code);
}
