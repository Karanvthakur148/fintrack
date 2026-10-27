import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:fintrack/features/analytics/presentation/pages/analytics_page.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:fintrack/features/budgets/presentation/pages/budgets_page.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fintrack/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fintrack/features/settings/presentation/pages/settings_page.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_event.dart';
import 'package:fintrack/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:fintrack/injection_container.dart';

/// Bottom-navigation shell. Feature BLoCs live as long as the shell and
/// all subscribe to the same repository streams.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) => sl<DashboardBloc>()..add(const DashboardStarted()),
        ),
        BlocProvider<TransactionListBloc>(
          create: (_) => sl<TransactionListBloc>()..add(const TransactionListStarted()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (_) => sl<AnalyticsBloc>()..add(const AnalyticsStarted()),
        ),
        BlocProvider<BudgetsBloc>(
          create: (_) => sl<BudgetsBloc>()..add(const BudgetsStarted()),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            DashboardPage(onSeeAllTransactions: () => setState(() => _index = 1)),
            const AllTransactionsPage(),
            const AnalyticsPage(),
            const BudgetsPage(),
            const SettingsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings_rounded),
              label: 'Budgets',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
