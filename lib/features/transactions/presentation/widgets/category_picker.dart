import 'package:flutter/material.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_visuals.dart';

/// Wrap of selectable category chips.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
    super.key,
    this.errorText,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in categories)
              ChoiceChip(
                avatar: Icon(
                  CategoryVisuals.of(category.id).icon,
                  size: 18,
                  color: CategoryVisuals.of(category.id).color,
                ),
                label: Text(category.name),
                selected: category.id == selectedId,
                onSelected: (_) => onChanged(category.id),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, left: AppSpacing.sm),
            child: Text(
              errorText!,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
