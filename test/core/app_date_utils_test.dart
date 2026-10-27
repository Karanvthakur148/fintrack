import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daysInMonth handles leap years', () {
    expect(AppDateUtils.daysInMonth(2024, 2), 29);
    expect(AppDateUtils.daysInMonth(2000, 2), 29);
    expect(AppDateUtils.daysInMonth(2023, 2), 28);
    expect(AppDateUtils.daysInMonth(2100, 2), 28);
    expect(AppDateUtils.daysInMonth(2025, 12), 31);
  });

  test('month boundaries roll over the year', () {
    expect(AppDateUtils.startOfNextMonth(DateTime(2024, 12, 15)), DateTime(2025));
    expect(AppDateUtils.endOfMonth(DateTime(2024, 2, 10)), DateTime(2024, 2, 29));
    expect(AppDateUtils.monthKey(DateTime(2024, 3, 5)), '2024-03');
  });

  group('isInRange', () {
    final from = DateTime(2024, 3, 10, 18);
    final to = DateTime(2024, 3, 12, 6);

    test('includes the whole start and end days', () {
      expect(AppDateUtils.isInRange(DateTime(2024, 3, 10, 0, 1), from: from), isTrue);
      expect(
        AppDateUtils.isInRange(DateTime(2024, 3, 12, 23, 59), from: from, to: to),
        isTrue,
      );
    });
    test('excludes days outside the range', () {
      expect(
        AppDateUtils.isInRange(DateTime(2024, 3, 9, 23, 59), from: from, to: to),
        isFalse,
      );
      expect(AppDateUtils.isInRange(DateTime(2024, 3, 13), from: from, to: to), isFalse);
    });
    test('open-ended bounds', () {
      expect(AppDateUtils.isInRange(DateTime(1999)), isTrue);
    });
  });

  test('weeks start on Monday and cross month ends', () {
    expect(AppDateUtils.startOfWeek(DateTime(2024, 3, 10)), DateTime(2024, 3, 4));
    final days = AppDateUtils.daysOfWeek(DateTime(2024, 2, 28));
    expect(days.length, 7);
    expect(days.first, DateTime(2024, 2, 26));
    expect(days.last, DateTime(2024, 3, 3));
  });
}
