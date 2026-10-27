import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_state.dart';

/// Opens the filter sheet. Filters apply live through [TransactionListBloc].
Future<void> showTransactionFilterSheet(BuildContext context) {
  final bloc = context.read<TransactionListBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const FilterSheet(),
    ),
  );
}

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  Future<void> _pickRange(BuildContext context, TransactionFilter filter) async {
    final bloc = context.read<TransactionListBloc>();
    final from = filter.from;
    final to = filter.to;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          (from != null && to != null) ? DateTimeRange(start: from, end: to) : null,
    );
    if (picked != null) {
      bloc.add(TransactionDateRangeChanged(from: picked.start, to: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TransactionListBloc, TransactionListState>(
      builder: (context, state) {
        final filter = state.filter;
        final bloc = context.read<TransactionListBloc>();
        final categories =
            filter.type == null ? Categories.all : Categories.forType(filter.type!);
        final from = filter.from;
        final to = filter.to;
        final rangeLabel = (from != null && to != null)
            ? '${AppFormats.dayMonthYear.format(from)} – '
                '${AppFormats.dayMonthYear.format(to)}'
            : 'Any date';

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Filters', style: theme.textTheme.titleLarge),
                    ),
                    TextButton(
                      onPressed: filter.activeFilterCount == 0
                          ? null
                          : () {
                              bloc
                                ..add(const TransactionTypeFilterChanged(null))
                                ..add(const TransactionCategoryFilterChanged(null))
                                ..add(const TransactionDateRangeChanged())
                                ..add(const TransactionSortChanged(
                                  TransactionSort.newestFirst,
                                ));
                            },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Type', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<TransactionType?>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                    ),
                  ],
                  selected: {filter.type},
                  onSelectionChanged: (s) =>
                      bloc.add(TransactionTypeFilterChanged(s.first)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Category', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final category in categories)
                      ChoiceChip(
                        label: Text(
                          filter.type == null
                              ? '${category.name} (${category.type.label})'
                              : category.name,
                        ),
                        selected: filter.categoryId == category.id,
                        onSelected: (selected) => bloc.add(
                          TransactionCategoryFilterChanged(
                            selected ? category.id : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Date range', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickRange(context, filter),
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(rangeLabel),
                      ),
                    ),
                    if (from != null || to != null)
                      IconButton(
                        tooltip: 'Clear date range',
                        onPressed: () => bloc.add(const TransactionDateRangeChanged()),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Sort by', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<TransactionSort>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: TransactionSort.newestFirst,
                      label: Text('Newest'),
                    ),
                    ButtonSegment(
                      value: TransactionSort.oldestFirst,
                      label: Text('Oldest'),
                    ),
                  ],
                  selected: {filter.sort},
                  onSelectionChanged: (s) =>
                      bloc.add(TransactionSortChanged(s.first)),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Show ${state.visible.length} results'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
