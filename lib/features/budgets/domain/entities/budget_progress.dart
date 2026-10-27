import 'package:equatable/equatable.dart';
import 'package:fintrack/core/utils/money.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';

enum BudgetStatus { onTrack, warning, exceeded }

/// A budget together with the actual spending against it.
class BudgetProgress extends Equatable {
  const BudgetProgress({required this.budget, required this.spentMinor});

  /// Warning starts at 80% of the limit.
  static const int warningPercent = 80;

  final Budget budget;
  final int spentMinor;

  int get remainingMinor => budget.limitMinor - spentMinor;

  int get overspentMinor => spentMinor > budget.limitMinor
      ? spentMinor - budget.limitMinor
      : 0;

  /// 0.0 .. n (can exceed 1.0 when over budget).
  double get percentUsed => Money.ratio(spentMinor, budget.limitMinor);

  BudgetStatus get status {
    if (spentMinor > budget.limitMinor) return BudgetStatus.exceeded;
    // Integer comparison avoids floating-point edge cases.
    if (spentMinor * 100 >= budget.limitMinor * warningPercent) {
      return BudgetStatus.warning;
    }
    return BudgetStatus.onTrack;
  }

  @override
  List<Object?> get props => [budget, spentMinor];
}
