import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/errors/exceptions.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';

/// Business rules every stored transaction must satisfy.
abstract final class TransactionValidator {
  /// Throws [ValidationException] when [transaction] is invalid.
  static void validate(Transaction transaction) {
    if (transaction.id.trim().isEmpty) {
      throw const ValidationException('Transaction id is missing.');
    }
    final title = transaction.title.trim();
    if (title.isEmpty) {
      throw const ValidationException('Title cannot be empty.');
    }
    if (title.length > AppConstants.maxTitleLength) {
      throw const ValidationException('Title is too long.');
    }
    if (transaction.amountMinor <= 0) {
      throw const ValidationException('Amount must be greater than zero.');
    }
    final category = Categories.byId(transaction.categoryId);
    if (category == null) {
      throw const ValidationException('Unknown category.');
    }
    if (category.type != transaction.type) {
      throw const ValidationException(
        'Category does not match the transaction type.',
      );
    }
    if ((transaction.notes?.length ?? 0) > AppConstants.maxNotesLength) {
      throw const ValidationException('Notes are too long.');
    }
  }
}
