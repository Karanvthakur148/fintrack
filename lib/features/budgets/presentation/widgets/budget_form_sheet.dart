import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/money.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/features/budgets/domain/entities/budget.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_picker.dart';

class BudgetFormResult {
  const BudgetFormResult({required this.categoryId, required this.limitMinor});

  final String categoryId;
  final int limitMinor;
}

/// Bottom sheet to create or edit a budget. Pops a [BudgetFormResult].
class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({
    required this.availableCategories,
    required this.currency,
    super.key,
    this.initial,
  });

  /// Expense categories that may be chosen (already-budgeted ones removed).
  final List<Category> availableCategories;
  final AppCurrency currency;
  final Budget? initial;

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _limit;
  String? _categoryId;
  bool _categoryMissing = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _limit = TextEditingController(
      text: initial == null ? '' : Money.toPlainString(initial.limitMinor),
    );
    _categoryId = initial?.categoryId;
  }

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  void _save() {
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryMissing = _categoryId == null);
    final categoryId = _categoryId;
    final limit = Money.parse(_limit.text);
    if (!valid || categoryId == null || limit == null) return;
    Navigator.of(context).pop(
      BudgetFormResult(categoryId: categoryId, limitMinor: limit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editing ? 'Edit budget' : 'New budget',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Category', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                CategoryPicker(
                  categories: widget.availableCategories,
                  selectedId: _categoryId,
                  errorText: _categoryMissing ? 'Please select a category' : null,
                  onChanged: (id) => setState(() {
                    _categoryId = id;
                    _categoryMissing = false;
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _limit,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Monthly limit',
                    prefixText: '${widget.currency.symbol} ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(editing ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
