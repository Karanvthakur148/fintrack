import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Contract for transaction persistence. Implemented in the data layer.
///
/// Implementations throw `CacheException` for storage problems and
/// `NotFoundException` when an id does not exist.
abstract interface class TransactionRepository {
  /// Emits the full list immediately, then again after every change.
  Stream<List<Transaction>> watchAll();

  Future<List<Transaction>> getAll();

  Future<Transaction> getById(String id);

  Future<void> add(Transaction transaction);

  Future<void> update(Transaction transaction);

  Future<void> delete(String id);

  Future<void> clear();
}
