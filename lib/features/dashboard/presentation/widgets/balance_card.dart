import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';

/// Hero card: total balance (all time) with total income and expenses.
class BalanceCard extends StatelessWidget {
  const BalanceCard({required this.summary, required this.currency, super.key});

  final FinancialSummary summary;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.finColors;
    final theme = Theme.of(context);
    final onHero = colors.onHero;

    return Semantics(
      label: 'Total balance '
          '${CurrencyFormatter.format(summary.balanceMinor, currency)}',
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        gradient: LinearGradient(
          colors: [colors.heroStart, colors.heroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total balance',
              style: theme.textTheme.labelLarge?.copyWith(
                color: onHero.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: summary.balanceMinor.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyFormatter.format(value.round(), currency),
                  style: theme.textTheme.displaySmall?.copyWith(color: onHero),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    value: CurrencyFormatter.format(summary.incomeMinor, currency),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expenses',
                    value: CurrencyFormatter.format(summary.expenseMinor, currency),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onHero = context.finColors.onHero;
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: onHero.withValues(alpha: 0.18),
          child: Icon(icon, size: 16, color: onHero),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onHero.withValues(alpha: 0.8),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(color: onHero),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
