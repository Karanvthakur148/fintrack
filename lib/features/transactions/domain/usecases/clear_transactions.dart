import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class ClearTransactions {
  const ClearTransactions(this._repository);

  final TransactionRepository _repository;

  Future<void> call() => _repository.clear();
}
