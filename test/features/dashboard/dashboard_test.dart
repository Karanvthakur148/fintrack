import 'package:fintrack/features/dashboard/domain/usecases/build_dashboard_data.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/in_memory_data_sources.dart';

void main() {
  final now = DateTime(2024, 3, 15);
  const build = BuildDashboardData();

  group('BuildDashboardData', () {
    test('empty database produces zeros and no recent items', () {
      final data = build(const [], now);
      expect(data.total.balanceMinor, 0);
      expect(data.hasTransactions, isFalse);
      expect(data.weekly.length, 7);
      expect(data.monthly.length, 6);
    });

    test('totals are all-time, month summary is the current month only', () {
      final data = build([
        buildIncome(amountMinor: 100000, date: DateTime(2024, 3, 1)),
        buildTransaction(id: 'a', amountMinor: 20000, date: DateTime(2024, 3, 10)),
        buildTransaction(id: 'b', amountMinor: 5000, date: DateTime(2024, 2, 28)),
      ], now);
      expect(data.total.balanceMinor, 75000);
      expect(data.month.incomeMinor, 100000);
      expect(data.month.expenseMinor, 20000);
      expect(data.monthCategories.single.amountMinor, 20000);
    });

    test('recent keeps the 5 newest', () {
      final txs = [
        for (var i = 1; i <= 8; i++)
          buildTransaction(id: 'id$i', date: DateTime(2024, 3, i)),
      ];
      final data = build(txs, now);
      expect(data.recent.length, 5);
      expect(data.recent.first.id, 'id8');
    });
  });

  test('DashboardBloc refreshes when transactions change', () async {
    final repo = TransactionRepositoryImpl(InMemoryTransactionDataSource());
    final bloc = DashboardBloc(
      watchTransactions: WatchTransactions(repo),
      buildDashboardData: build,
      clock: () => now,
    )..add(const DashboardStarted());

    await bloc.stream.firstWhere((s) => s.status == DashboardStatus.success);
    await pumpEventQueue();

    final next = expectLater(
      bloc.stream,
      emitsThrough(
        predicate<DashboardState>((s) => s.data?.total.expenseMinor == 12345),
      ),
    );
    await repo.add(buildTransaction(amountMinor: 12345));
    await next;
    await bloc.close();
  });
}
