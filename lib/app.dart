import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/app_router.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_state.dart';
import 'package:fintrack/injection_container.dart';

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  static ThemeMode _themeMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: sl<SettingsBloc>()),
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (p, c) => p.settings.themeMode != c.settings.themeMode,
        builder: (context, state) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeMode(state.settings.themeMode),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}

/// Shown when local storage cannot be opened at startup.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: ErrorView(
            message: 'FinTrack could not open its local database.\n$message',
          ),
        ),
      ),
    );
  }
}
