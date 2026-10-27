import 'package:equatable/equatable.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => const [];
}

final class SettingsThemeModeChanged extends SettingsEvent {
  const SettingsThemeModeChanged(this.mode);

  final AppThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

final class SettingsCurrencyChanged extends SettingsEvent {
  const SettingsCurrencyChanged(this.currency);

  final AppCurrency currency;

  @override
  List<Object?> get props => [currency];
}

final class SettingsClearDataRequested extends SettingsEvent {
  const SettingsClearDataRequested();
}

final class SettingsMessageDismissed extends SettingsEvent {
  const SettingsMessageDismissed();
}
