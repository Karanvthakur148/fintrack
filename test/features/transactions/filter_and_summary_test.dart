import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/domain/usecases/calculate_summary.dart';
import 'package:fintrack/features/transactions/domain/usecases/filter_transactions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  const filter = FilterTransactions();
  const summary = CalculateSummary();

  final txs = [
    buildTransaction(id: 'a', title: 'Groceries', amountMinor: 30000, date: DateTime(2024, 3, 1)),
    buildTransaction(
      id: 'b',
      title: 'Bus pass',
      amountMinor: 5000,
      categoryId: 'transport',
      date: DateTime(2024, 3, 10),
    ),
    buildIncome(id: 'c', amountMinor: 100000, date: DateTime(2024, 3, 31)),
    buildTransaction(id: 'd', title: 'Late snack', amountMinor: 1000, date: DateTime(2024, 4, 1)),
  ];

  group('FilterTransactions', () {
    test('searches titles case-insensitively', () {
      final r = filter(txs, const TransactionFilter(query: 'GROC'));
      expect(r.map((t) => t.id), ['a']);
    });

    test('filters by type and category', () {
      expect(filter(txs, const TransactionFilter(type: TransactionType.income)).map((t) => t.id), ['c']);
      expect(filter(txs, const TransactionFilter(categoryId: 'transport')).map((t) => t.id), ['b']);
    });

    test('date range includes both boundary days, excludes others', () {
      final r = filter(
        txs,
        TransactionFilter(from: DateTime(2024, 3, 1), to: DateTime(2024, 3, 31)),
      );
      expect(r.map((t) => t.id).toSet(), {'a', 'b', 'c'});
    });

    test('sorts newest and oldest first', () {
      expect(filter(txs, const TransactionFilter()).map((t) => t.id), ['d', 'c', 'b', 'a']);
      expect(
        filter(txs, const TransactionFilter(sort: TransactionSort.oldestFirst)).map((t) => t.id),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('switching type drops a category of the other type', () {
      final f = const TransactionFilter(categoryId: 'food').withType(TransactionType.income);
      expect(f.categoryId, isNull);
    });
  });

  group('CalculateSummary', () {
    test('balance is income minus expenses; types never mix', () {
      final s = summary(txs);
      expect(s.incomeMinor, 100000);
      expect(s.expenseMinor, 36000);
      expect(s.balanceMinor, 64000);
    });

    test('respects the month boundary (March only)', () {
      final s = summary(txs, from: DateTime(2024, 3), to: DateTime(2024, 3, 31));
      expect(s.expenseMinor, 35000);
      expect(s.incomeMinor, 100000);
    });

    test('empty list gives zeros', () {
      expect(summary(const []), FinancialSummary.empty);
    });

    test('is exact with fractional amounts', () {
      final s = summary([
        buildTransaction(id: '1', amountMinor: 10),
        buildTransaction(id: '2', amountMinor: 20),
      ]);
      expect(s.expenseMinor, 30);
    });
  });
}
