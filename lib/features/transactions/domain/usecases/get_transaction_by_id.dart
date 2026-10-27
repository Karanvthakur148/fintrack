import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionById {
  const GetTransactionById(this._repository);

  final TransactionRepository _repository;

  Future<Transaction> call(String id) {
    if (id.trim().isEmpty) {
      throw const ValidationException('Transaction id is missing.');
    }
    return _repository.getById(id);
  }
}
