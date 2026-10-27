import 'package:equatable/equatable.dart';

/// A monthly spending limit for one expense category.
/// Uniquely identified by (categoryId, monthKey).
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitMinor,
    required this.monthKey,
  });

  final String id;
  final String categoryId;
  final int limitMinor;

  /// Period identifier `yyyy-MM`, e.g. `2025-03`.
  final String monthKey;

  Budget copyWith({String? categoryId, int? limitMinor}) => Budget(
        id: id,
        categoryId: categoryId ?? this.categoryId,
        limitMinor: limitMinor ?? this.limitMinor,
        monthKey: monthKey,
      );

  @override
  List<Object?> get props => [id, categoryId, limitMinor, monthKey];
}
