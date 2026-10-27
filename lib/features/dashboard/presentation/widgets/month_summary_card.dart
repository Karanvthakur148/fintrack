import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/core/widgets/amount_text.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/features/transactions/domain/entities/financial_summary.dart';

/// Current calendar month summary.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    required this.summary,
    required this.currency,
    required this.now,
    super.key,
  });

  final FinancialSummary summary;
  final AppCurrency currency;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget cell(String label, int minor, AmountTone tone) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AmountText(minor: minor, currency: currency, tone: tone),
              ),
            ],
          ),
        );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This month · ${AppFormats.monthYear.format(now)}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              cell('Income', summary.incomeMinor, AmountTone.income),
              cell('Expenses', summary.expenseMinor, AmountTone.expense),
              cell('Net', summary.balanceMinor, AmountTone.neutral),
            ],
          ),
        ],
      ),
    );
  }
}
