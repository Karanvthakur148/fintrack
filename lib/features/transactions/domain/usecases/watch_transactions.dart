import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

/// The single source of truth stream shared by Dashboard, Analytics,
/// Budgets and the transaction list.
class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<Transaction>> call() => _repository.watchAll();
}
