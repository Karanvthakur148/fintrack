import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  /// Throws `NotFoundException` when the id does not exist.
  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Transaction id is missing.');
    }
    await _repository.delete(id);
  }
}
