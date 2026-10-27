import 'package:flutter/material.dart';
import 'package:fintrack/app_router.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// Shortcuts to add an income or an expense.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.finColors;

    Widget action(String label, IconData icon, Color color, TransactionType type) {
      return Expanded(
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: onColorFor(color),
          ),
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.addTransaction,
            arguments: type,
          ),
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return Row(
      children: [
        action('Add income', Icons.add_circle_outline_rounded, colors.income,
            TransactionType.income),
        const SizedBox(width: AppSpacing.md),
        action('Add expense', Icons.remove_circle_outline_rounded, colors.expense,
            TransactionType.expense),
      ],
    );
  }
}
