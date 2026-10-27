import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_repository.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class LoadSettings {
  const LoadSettings(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.load();
}

class SaveThemeMode {
  const SaveThemeMode(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppThemeMode mode) => _repository.saveThemeMode(mode);
}

class SaveCurrency {
  const SaveCurrency(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppCurrency currency) => _repository.saveCurrency(currency);
}

/// Deletes all transactions and budgets. Settings are intentionally kept.
class ClearAllData {
  const ClearAllData({
    required TransactionRepository transactions,
    required BudgetRepository budgets,
  })  : _transactions = transactions,
        _budgets = budgets;

  final TransactionRepository _transactions;
  final BudgetRepository _budgets;

  Future<void> call() async {
    await _transactions.clear();
    await _budgets.clear();
  }
}
