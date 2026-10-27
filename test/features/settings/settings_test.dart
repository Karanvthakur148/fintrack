import 'package:bloc_test/bloc_test.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:fintrack/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/domain/usecases/settings_usecases.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_event.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_state.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

class FakeSettingsSource implements SettingsLocalDataSource {
  final Map<String, String> values = {};

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

void main() {
  late FakeSettingsSource source;
  late SettingsRepositoryImpl settingsRepo;
  late TransactionRepositoryImpl txRepo;
  late BudgetRepositoryImpl budgetRepo;

  SettingsBloc makeBloc() => SettingsBloc(
        saveThemeMode: SaveThemeMode(settingsRepo),
        saveCurrency: SaveCurrency(settingsRepo),
        clearAllData: ClearAllData(transactions: txRepo, budgets: budgetRepo),
      );

  setUp(() {
    source = FakeSettingsSource();
    settingsRepo = SettingsRepositoryImpl(source);
    txRepo = TransactionRepositoryImpl(InMemoryTransactionDataSource());
    budgetRepo = BudgetRepositoryImpl(InMemoryBudgetDataSource());
  });

  test('load returns defaults when nothing is stored or data is corrupt', () async {
    expect(await settingsRepo.load(), AppSettings.defaults);
    source.values[AppConstants.prefThemeMode] = 'rainbow';
    source.values[AppConstants.prefCurrency] = 'XYZ';
    expect(await settingsRepo.load(), AppSettings.defaults);
  });

  test('saved settings are loaded back', () async {
    await settingsRepo.saveThemeMode(AppThemeMode.dark);
    await settingsRepo.saveCurrency(AppCurrency.usd);
    expect(
      await settingsRepo.load(),
      const AppSettings(themeMode: AppThemeMode.dark, currency: AppCurrency.usd),
    );
  });

  blocTest<SettingsBloc, SettingsState>(
    'changes theme and currency and persists them',
    build: makeBloc,
    act: (bloc) async {
      bloc.add(const SettingsThemeModeChanged(AppThemeMode.dark));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SettingsCurrencyChanged(AppCurrency.usd));
    },
    expect: () => [
      const SettingsState(
        settings: AppSettings(themeMode: AppThemeMode.dark, currency: AppCurrency.inr),
      ),
      const SettingsState(
        settings: AppSettings(themeMode: AppThemeMode.dark, currency: AppCurrency.usd),
      ),
    ],
    verify: (_) {
      expect(source.values[AppConstants.prefThemeMode], 'dark');
      expect(source.values[AppConstants.prefCurrency], 'USD');
    },
  );

  test('clear all data empties transactions and budgets but keeps settings', () async {
    await txRepo.add(buildTransaction());
    await budgetRepo.add(buildBudget());
    final bloc = makeBloc();
    bloc.add(const SettingsCurrencyChanged(AppCurrency.usd));
    await bloc.stream.firstWhere((s) => s.settings.currency == AppCurrency.usd);

    bloc.add(const SettingsClearDataRequested());
    await bloc.stream.firstWhere((s) => s.message == 'All data cleared.');

    expect(await txRepo.getAll(), isEmpty);
    expect(await budgetRepo.getAll(), isEmpty);
    expect(bloc.state.settings.currency, AppCurrency.usd);
    expect(bloc.state.isClearing, isFalse);
    await bloc.close();
  });
}
