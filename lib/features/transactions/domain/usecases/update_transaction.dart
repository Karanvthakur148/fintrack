import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/transactions/domain/usecases/validate_transaction.dart';

class UpdateTransaction {
  UpdateTransaction(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final TransactionRepository _repository;
  final DateTime Function() _clock;

  /// Throws `NotFoundException` when the id does not exist.
  Future<void> call(Transaction transaction) async {
    TransactionValidator.validate(transaction);
    final existing = await _repository.getById(transaction.id);
    await _repository.update(
      transaction.copyWith(
        createdAt: existing.createdAt,
        updatedAt: _clock(),
      ),
    );
  }
}
