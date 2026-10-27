import 'package:fintrack/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SettingsLocalDataSource {
  String? getString(String key);

  Future<void> setString(String key, String value);
}

class SharedPrefsSettingsDataSource implements SettingsLocalDataSource {
  SharedPrefsSettingsDataSource(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    final ok = await _prefs.setString(key, value);
    if (!ok) throw const CacheException('Could not save settings.');
  }
}
