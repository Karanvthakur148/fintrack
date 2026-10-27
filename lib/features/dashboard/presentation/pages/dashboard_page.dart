import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/app_router.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/core/widgets/loading_view.dart';
import 'package:fintrack/core/widgets/section_header.dart';
import 'package:fintrack/features/analytics/presentation/widgets/category_breakdown_list.dart';
import 'package:fintrack/features/analytics/presentation/widgets/chart_placeholder.dart';
import 'package:fintrack/features/analytics/presentation/widgets/monthly_comparison_chart.dart';
import 'package:fintrack/features/analytics/presentation/widgets/weekly_spending_chart.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:fintrack/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:fintrack/features/dashboard/presentation/widgets/month_summary_card.dart';
import 'package:fintrack/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:fintrack/features/settings/presentation/settings_context.dart';
import 'package:fintrack/features/transactions/presentation/widgets/transaction_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.onSeeAllTransactions, super.key});

  final VoidCallback onSeeAllTransactions;

  @override
  Widget build(BuildContext context) {
    final currency = context.currency;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName),  automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) return const LoadingView();
          final data = state.data;
          if (state.status == DashboardStatus.failure || data == null) {
            return ErrorView(
              message: state.failure?.message ?? 'Unable to load your data.',
              onRetry: () =>
                  context.read<DashboardBloc>().add(const DashboardStarted()),
            );
          }

          final now = DateTime.now();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: [
              BalanceCard(summary: data.total, currency: currency),
              const SizedBox(height: AppSpacing.lg),
              const QuickActions(),
              const SizedBox(height: AppSpacing.lg),
              MonthSummaryCard(summary: data.month, currency: currency, now: now),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Weekly spending'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: WeeklySpendingChart(data: data.weekly, currency: currency),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Monthly overview'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: MonthlyComparisonChart(
                  data: data.monthly,
                  currency: currency,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Expenses by category (this month)'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: data.monthCategories.isEmpty
                    ? const ChartPlaceholder(
                        message: 'No expenses this month',
                        height: 100,
                      )
                    : CategoryBreakdownList(
                        data: data.monthCategories,
                        currency: currency,
                        maxItems: 5,
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Recent transactions',
                actionLabel: data.hasTransactions ? 'See all' : null,
                onAction: onSeeAllTransactions,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: data.hasTransactions
                    ? Column(
                        children: [
                          for (final t in data.recent)
                            TransactionTile(
                              transaction: t,
                              currency: currency,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.editTransaction,
                                arguments: t.id,
                              ),
                            ),
                        ],
                      )
                    : EmptyState(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'No transactions yet',
                        message: 'Add an income or expense to see your summary.',
                        actionLabel: 'Add expense',
                        onAction: () =>
                            Navigator.pushNamed(context, AppRoutes.addTransaction),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
