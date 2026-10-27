import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';

/// Converts models to/from Firestore documents. Invalid documents map to
/// `null` and are ignored instead of crashing the app.
abstract final class FirestoreMappers {
  static String _str(Object? v, String fallback) => v is String ? v : fallback;

  static int _int(Object? v) => v is num ? v.toInt() : 0;

  static Map<String, dynamic> transactionToMap(TransactionModel m) => {
        'title': m.title,
        'amountMinor': m.amountMinor,
        'categoryId': m.categoryId,
        'type': m.type,
        'dateMs': m.dateMs,
        'notes': m.notes,
        'createdAtMs': m.createdAtMs,
        'updatedAtMs': m.updatedAtMs,
      };

  static TransactionModel? transactionFromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final title = data['title'];
    final amount = data['amountMinor'];
    if (title is! String || amount is! num) return null;
    final notes = data['notes'];
    return TransactionModel(
      id: id,
      title: title,
      amountMinor: amount.toInt(),
      categoryId: _str(data['categoryId'], 'other_expense'),
      type: _str(data['type'], 'expense'),
      dateMs: _int(data['dateMs']),
      notes: notes is String ? notes : null,
      createdAtMs: _int(data['createdAtMs']),
      updatedAtMs: _int(data['updatedAtMs']),
    );
  }

  static Map<String, dynamic> budgetToMap(BudgetModel m) => {
        'categoryId': m.categoryId,
        'limitMinor': m.limitMinor,
        'monthKey': m.monthKey,
        'updatedAtMs': m.updatedAtMs,
      };

  static BudgetModel? budgetFromMap(String id, Map<String, dynamic> data) {
    final category = data['categoryId'];
    final limit = data['limitMinor'];
    final month = data['monthKey'];
    if (category is! String || limit is! num || month is! String) return null;
    return BudgetModel(
      id: id,
      categoryId: category,
      limitMinor: limit.toInt(),
      monthKey: month,
      updatedAtMs: _int(data['updatedAtMs']),
    );
  }
}
