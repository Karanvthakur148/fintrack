import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/transactions/domain/usecases/validate_transaction.dart';

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(Transaction transaction) async {
    TransactionValidator.validate(transaction);
    await _repository.add(transaction);
  }
}
