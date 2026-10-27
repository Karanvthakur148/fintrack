import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_radii.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_visuals.dart';

/// Category rows with amount, share and a progress bar.
class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    required this.data,
    required this.currency,
    super.key,
    this.maxItems,
  });

  final List<CategoryAmount> data;
  final AppCurrency currency;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = maxItems == null ? data : data.take(maxItems!).toList();

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      CategoryVisuals.of(item.categoryId).color.withValues(alpha: 0.15),
                  child: Icon(
                    CategoryVisuals.of(item.categoryId).icon,
                    size: 18,
                    color: CategoryVisuals.of(item.categoryId).color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              Categories.nameOf(item.categoryId),
                              style: theme.textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.amountMinor, currency),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppRadii.pill,
                              child: LinearProgressIndicator(
                                value: item.share.clamp(0.0, 1.0),
                                minHeight: 6,
                                color: CategoryVisuals.of(item.categoryId).color,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(item.share * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
