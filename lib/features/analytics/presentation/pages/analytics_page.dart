import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/core/widgets/amount_text.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/core/widgets/loading_view.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_range.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:fintrack/features/analytics/presentation/widgets/category_breakdown_list.dart';
import 'package:fintrack/features/analytics/presentation/widgets/category_pie_chart.dart';
import 'package:fintrack/features/analytics/presentation/widgets/monthly_comparison_chart.dart';
import 'package:fintrack/features/analytics/presentation/widgets/weekly_spending_chart.dart';
import 'package:fintrack/features/settings/presentation/settings_context.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.currency;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading) return const LoadingView();
          if (state.status == AnalyticsStatus.failure) {
            return ErrorView(
              message: state.failure?.message ?? 'Unable to load analytics.',
              onRetry: () =>
                  context.read<AnalyticsBloc>().add(const AnalyticsStarted()),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: [
              _RangeSelector(selected: state.range),
              const SizedBox(height: AppSpacing.lg),
              _SummaryRow(state: state, currency: currency),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Spending by category',
                child: Column(
                  children: [
                    CategoryPieChart(data: state.distribution),
                    if (state.distribution.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      CategoryBreakdownList(
                        data: state.distribution,
                        currency: currency,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Weekly spending',
                trailing: _WeekNavigator(state: state),
                child: WeeklySpendingChart(
                  data: state.weekly,
                  currency: currency,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Income vs expense',
                child: MonthlyComparisonChart(
                  data: state.monthly,
                  currency: currency,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected});

  final AnalyticsRange selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in AnalyticsRange.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(range.label),
                selected: range == selected,
                onSelected: (_) =>
                    context.read<AnalyticsBloc>().add(AnalyticsRangeChanged(range)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state, required this.currency});

  final AnalyticsState state;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = state.summary;

    Widget stat(String label, int minor, AmountTone tone) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AmountText(
                  minor: minor,
                  currency: currency,
                  tone: tone,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        );

    return AppCard(
      child: Row(
        children: [
          stat('Income', summary.incomeMinor, AmountTone.income),
          stat('Expenses', summary.expenseMinor, AmountTone.expense),
          stat('Net', summary.balanceMinor, AmountTone.neutral),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({required this.state});

  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final start = state.weekStart;
    final label = start == null
        ? ''
        : '${AppFormats.dayMonth.format(start)} – '
            '${AppFormats.dayMonth.format(DateTime(start.year, start.month, start.day + 6))}';
    final bloc = context.read<AnalyticsBloc>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Previous week',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => bloc.add(const AnalyticsWeekShifted(-1)),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        IconButton(
          tooltip: 'Next week',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed:
              state.weekOffset >= 0 ? null : () => bloc.add(const AnalyticsWeekShifted(1)),
        ),
      ],
    );
  }
}
