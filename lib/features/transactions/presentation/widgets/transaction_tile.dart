import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/core/widgets/amount_text.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_visuals.dart';

/// One transaction row: category icon, title, category and date, amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.currency,
    super.key,
    this.onTap,
  });

  final Transaction transaction;
  final AppCurrency currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisuals.of(transaction.categoryId);
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: visual.color.withValues(alpha: 0.15),
        child: Icon(visual.icon, color: visual.color, size: 22),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '${Categories.nameOf(transaction.categoryId)} • '
        '${AppFormats.dayMonthYear.format(transaction.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      trailing: AmountText(
        minor: transaction.amountMinor,
        currency: currency,
        tone: transaction.isIncome ? AmountTone.income : AmountTone.expense,
      ),
    );
  }
}
