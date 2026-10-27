import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/domain/usecases/settings_usecases.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_event.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_state.dart';

/// App-wide settings. Created with the already-loaded [initial] settings so
/// the first frame uses the saved theme and currency (no flicker).
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SaveThemeMode saveThemeMode,
    required SaveCurrency saveCurrency,
    required ClearAllData clearAllData,
    AppSettings initial = AppSettings.defaults,
  })  : _saveThemeMode = saveThemeMode,
        _saveCurrency = saveCurrency,
        _clearAllData = clearAllData,
        super(SettingsState(settings: initial)) {
    on<SettingsThemeModeChanged>(_onThemeChanged);
    on<SettingsCurrencyChanged>(_onCurrencyChanged);
    on<SettingsClearDataRequested>(_onClearData);
    on<SettingsMessageDismissed>(
      (e, emit) => emit(state.copyWith(clearMessage: true)),
    );
  }

  final SaveThemeMode _saveThemeMode;
  final SaveCurrency _saveCurrency;
  final ClearAllData _clearAllData;

  Future<void> _onThemeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _saveThemeMode(event.mode);
      emit(state.copyWith(
        settings: state.settings.copyWith(themeMode: event.mode),
      ));
    } catch (_) {
      emit(state.copyWith(
        message: 'Could not save the theme.',
        messageIsError: true,
      ));
    }
  }

  Future<void> _onCurrencyChanged(
    SettingsCurrencyChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _saveCurrency(event.currency);
      emit(state.copyWith(
        settings: state.settings.copyWith(currency: event.currency),
      ));
    } catch (_) {
      emit(state.copyWith(
        message: 'Could not save the currency.',
        messageIsError: true,
      ));
    }
  }

  Future<void> _onClearData(
    SettingsClearDataRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isClearing: true));
    try {
      await _clearAllData();
      emit(state.copyWith(isClearing: false, message: 'All data cleared.'));
    } catch (_) {
      emit(state.copyWith(
        isClearing: false,
        message: 'Could not clear data. Please try again.',
        messageIsError: true,
      ));
    }
  }
}
