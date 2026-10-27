import 'package:equatable/equatable.dart';

/// Total for one category plus its share (0..1) of the grand total.
class CategoryAmount extends Equatable {
  const CategoryAmount({
    required this.categoryId,
    required this.amountMinor,
    required this.share,
  });

  final String categoryId;
  final int amountMinor;
  final double share;

  @override
  List<Object?> get props => [categoryId, amountMinor, share];
}

/// Expense total for one calendar day.
class DailyAmount extends Equatable {
  const DailyAmount({required this.date, required this.amountMinor});

  final DateTime date;
  final int amountMinor;

  @override
  List<Object?> get props => [date, amountMinor];
}

/// Income and expense totals for one calendar month.
class MonthlyTotals extends Equatable {
  const MonthlyTotals({
    required this.month,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  /// First day of the month.
  final DateTime month;
  final int incomeMinor;
  final int expenseMinor;

  @override
  List<Object?> get props => [month, incomeMinor, expenseMinor];
}
