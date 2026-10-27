import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_radii.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/features/budgets/domain/entities/budget_progress.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_visuals.dart';

enum BudgetMenuAction { edit, delete }

/// Budget vs actual spending for one category, with a status warning.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    required this.progress,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final BudgetProgress progress;
  final AppCurrency currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Color statusColor(BuildContext context, BudgetStatus status) {
    final colors = context.finColors;
    return switch (status) {
      BudgetStatus.onTrack => colors.income,
      BudgetStatus.warning => colors.warning,
      BudgetStatus.exceeded => colors.expense,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = progress.budget;
    final visual = CategoryVisuals.of(budget.categoryId);
    final color = statusColor(context, progress.status);
    final percent = (progress.percentUsed * 100).round();

    final statusText = switch (progress.status) {
      BudgetStatus.onTrack =>
        '${CurrencyFormatter.format(progress.remainingMinor, currency)} left',
      BudgetStatus.warning => progress.remainingMinor == 0
          ? 'Budget fully used'
          : 'Almost there · ${CurrencyFormatter.format(progress.remainingMinor, currency)} left',
      BudgetStatus.exceeded =>
        'Over by ${CurrencyFormatter.format(progress.overspentMinor, currency)}',
    };

    return AppCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: visual.color.withValues(alpha: 0.15),
                child: Icon(visual.icon, color: visual.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Categories.nameOf(budget.categoryId),
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${CurrencyFormatter.format(progress.spentMinor, currency)} of '
                      '${CurrencyFormatter.format(budget.limitMinor, currency)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<BudgetMenuAction>(
                tooltip: 'Budget options',
                onSelected: (action) => action == BudgetMenuAction.edit
                    ? onEdit()
                    : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: BudgetMenuAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: BudgetMenuAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.percentUsed.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: AppRadii.pill,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                color: color,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (progress.status != BudgetStatus.onTrack) ...[
                Icon(
                  progress.status == BudgetStatus.exceeded
                      ? Icons.error_rounded
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('$percent%', style: theme.textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }
}
