import 'package:fintrack/features/analytics/domain/entities/analytics_range.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_category_distribution.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_monthly_comparison.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_weekly_spending.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('ComputeCategoryDistribution', () {
    const compute = ComputeCategoryDistribution();

    test('sums expenses per category, largest first, shares add up', () {
      final r = compute([
        buildTransaction(id: '1', amountMinor: 30000),
        buildTransaction(id: '2', amountMinor: 10000),
        buildTransaction(id: '3', amountMinor: 60000, categoryId: 'bills'),
        buildIncome(),
      ]);
      expect(r.map((c) => c.categoryId), ['bills', 'food']);
      expect(r.first.amountMinor, 60000);
      expect(r.fold<double>(0, (s, c) => s + c.share), closeTo(1, 1e-9));
    });

    test('empty data and date filter', () {
      expect(compute(const []), isEmpty);
      final r = compute(
        [buildTransaction(date: DateTime(2024, 1, 5))],
        from: DateTime(2024, 3),
        to: DateTime(2024, 3, 31),
      );
      expect(r, isEmpty);
    });
  });

  group('ComputeWeeklySpending', () {
    const compute = ComputeWeeklySpending();

    test('returns seven days Monday-first with expenses only', () {
      // 13 March 2024 is a Wednesday; week is Mon 11 - Sun 17.
      final r = compute([
        buildTransaction(id: '1', amountMinor: 100, date: DateTime(2024, 3, 11)),
        buildTransaction(id: '2', amountMinor: 200, date: DateTime(2024, 3, 11)),
        buildTransaction(id: '3', amountMinor: 700, date: DateTime(2024, 3, 17)),
        buildTransaction(id: '4', amountMinor: 999, date: DateTime(2024, 3, 18)),
        buildIncome(date: DateTime(2024, 3, 12)),
      ], DateTime(2024, 3, 13));
      expect(r.length, 7);
      expect(r.first.date, DateTime(2024, 3, 11));
      expect(r.map((d) => d.amountMinor).toList(), [300, 0, 0, 0, 0, 0, 700]);
    });
  });

  group('ComputeMonthlyComparison', () {
    const compute = ComputeMonthlyComparison();

    test('covers the last N months, including empty ones, across a year change', () {
      final r = compute(
        [
          buildIncome(date: DateTime(2023, 12, 20), amountMinor: 1000),
          buildTransaction(date: DateTime(2024, 2, 29), amountMinor: 400),
        ],
        now: DateTime(2024, 2, 10),
        months: 4,
      );
      expect(r.map((m) => m.month), [
        DateTime(2023, 11),
        DateTime(2023, 12),
        DateTime(2024),
        DateTime(2024, 2),
      ]);
      expect(r[1].incomeMinor, 1000);
      expect(r[2].incomeMinor + r[2].expenseMinor, 0);
      expect(r[3].expenseMinor, 400);
    });
  });

  test('AnalyticsRange bounds', () {
    final now = DateTime(2024, 2, 10);
    expect(AnalyticsRange.thisMonth.from(now), DateTime(2024, 2));
    expect(AnalyticsRange.thisMonth.to(now), DateTime(2024, 2, 29));
    expect(AnalyticsRange.last3Months.from(now), DateTime(2023, 12));
    expect(AnalyticsRange.allTime.from(now), isNull);
  });
}
