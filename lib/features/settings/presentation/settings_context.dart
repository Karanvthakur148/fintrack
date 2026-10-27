import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_bloc.dart';

extension SettingsContext on BuildContext {
  /// Selected currency; rebuilds the widget when it changes.
  /// Only call inside `build`.
  AppCurrency get currency =>
      select((SettingsBloc bloc) => bloc.state.settings.currency);

  /// Selected currency without subscribing (use in callbacks).
  AppCurrency get currencyNow => read<SettingsBloc>().state.settings.currency;
}
