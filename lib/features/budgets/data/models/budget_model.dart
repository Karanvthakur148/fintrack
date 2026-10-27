import 'package:fintrack/features/budgets/domain/entities/budget.dart';

/// Hive representation of a [Budget].
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitMinor,
    required this.monthKey,
    required this.updatedAtMs,
  });

  final String id;
  final String categoryId;
  final int limitMinor;
  final String monthKey;

  /// Last modification time; used to resolve sync conflicts (newest wins).
  final int updatedAtMs;

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
        id: b.id,
        categoryId: b.categoryId,
        limitMinor: b.limitMinor,
        monthKey: b.monthKey,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );

  Budget toEntity() => Budget(
        id: id,
        categoryId: categoryId,
        limitMinor: limitMinor,
        monthKey: monthKey,
      );
}
