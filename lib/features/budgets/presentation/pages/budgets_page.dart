import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_radii.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/app_snackbar.dart';
import 'package:fintrack/core/widgets/confirm_dialog.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/core/widgets/loading_view.dart';
import 'package:fintrack/features/budgets/domain/entities/budget_progress.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_event.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_state.dart';
import 'package:fintrack/features/budgets/presentation/widgets/budget_form_sheet.dart';
import 'package:fintrack/features/budgets/presentation/widgets/budget_progress_card.dart';
import 'package:fintrack/features/settings/presentation/settings_context.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  Future<void> _openForm(BuildContext context, {BudgetProgress? editing}) async {
    final bloc = context.read<BudgetsBloc>();
    final currency = context.currencyNow;
    final used = bloc.state.progress.map((p) => p.budget.categoryId).toSet();
    if (editing != null) used.remove(editing.budget.categoryId);
    final available =
        Categories.expense.where((c) => !used.contains(c.id)).toList();

    if (available.isEmpty) {
      showAppSnackBar(
        context,
        'Every expense category already has a budget for this month.',
      );
      return;
    }

    final result = await showModalBottomSheet<BudgetFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BudgetFormSheet(
        availableCategories: available,
        currency: currency,
        initial: editing?.budget,
      ),
    );
    if (result == null) return;

    if (editing == null) {
      bloc.add(BudgetCreateRequested(
        categoryId: result.categoryId,
        limitMinor: result.limitMinor,
      ));
    } else {
      bloc.add(BudgetUpdateRequested(
        budget: editing.budget,
        categoryId: result.categoryId,
        limitMinor: result.limitMinor,
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, BudgetProgress p) async {
    final bloc = context.read<BudgetsBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete budget?',
      message:
          'The ${Categories.nameOf(p.budget.categoryId)} budget will be removed. '
          'Your transactions are not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) bloc.add(BudgetDeleteRequested(p.budget.id));
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.currency;

    return BlocListener<BudgetsBloc, BudgetsState>(
      listenWhen: (p, c) =>
          c.actionError != null && p.actionError != c.actionError,
      listener: (context, state) {
        showAppSnackBar(context, state.actionError!, isError: true);
        context.read<BudgetsBloc>().add(const BudgetsErrorDismissed());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Budgets')),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'home_budget',

          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New budget'),
        ),
        body: BlocBuilder<BudgetsBloc, BudgetsState>(
          builder: (context, state) {
            if (state.status == BudgetsStatus.loading) return const LoadingView();
            if (state.status == BudgetsStatus.failure) {
              return ErrorView(
                message: state.failure?.message ?? 'Unable to load budgets.',
                onRetry: () =>
                    context.read<BudgetsBloc>().add(const BudgetsStarted()),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                96,
              ),
              children: [
                _MonthSelector(month: state.month),
                const SizedBox(height: AppSpacing.lg),
                if (state.progress.isEmpty)
                  const SizedBox(
                    height: 360,
                    child: EmptyState(
                      icon: Icons.savings_rounded,
                      title: 'No budgets for this month',
                      message:
                          'Set a monthly limit for a category to track your spending.',
                    ),
                  )
                else ...[
                  _OverviewCard(state: state),
                  const SizedBox(height: AppSpacing.lg),
                  for (final p in state.progress) ...[
                    BudgetProgressCard(
                      progress: p,
                      currency: currency,
                      onEdit: () => _openForm(context, editing: p),
                      onDelete: () => _confirmDelete(context, p),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BudgetsBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => bloc.add(
            BudgetsMonthChanged(DateTime(month.year, month.month - 1)),
          ),
        ),
        Text(
          AppFormats.monthYear.format(month),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => bloc.add(
            BudgetsMonthChanged(DateTime(month.year, month.month + 1)),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.state});

  final BudgetsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.currency;
    final colors = context.finColors;
    final limit = state.totalLimitMinor;
    final spent = state.totalSpentMinor;
    final ratio = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final over = spent > limit;

    String? alert;
    Color? alertColor;
    if (state.exceededCount > 0) {
      alert = '${state.exceededCount} budget(s) exceeded';
      alertColor = colors.expense;
    } else if (state.warningCount > 0) {
      alert = '${state.warningCount} budget(s) close to the limit';
      alertColor = colors.warning;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly overview', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spent', style: theme.textTheme.bodySmall),
                    Text(
                      CurrencyFormatter.format(spent, currency),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budgeted', style: theme.textTheme.bodySmall),
                    Text(
                      CurrencyFormatter.format(limit, currency),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadii.pill,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: over ? colors.expense : colors.income,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          if (alert != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: alertColor),
                const SizedBox(width: 6),
                Text(
                  alert,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
