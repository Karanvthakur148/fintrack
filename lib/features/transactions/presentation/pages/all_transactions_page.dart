import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/app_router.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/widgets/app_snackbar.dart';
import 'package:fintrack/core/widgets/confirm_dialog.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/core/widgets/loading_view.dart';
import 'package:fintrack/features/settings/presentation/settings_context.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_state.dart';
import 'package:fintrack/features/transactions/presentation/widgets/filter_sheet.dart';
import 'package:fintrack/features/transactions/presentation/widgets/transaction_tile.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context, Transaction t) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete transaction?',
      message: '"${t.title}" will be removed permanently.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<TransactionListBloc>().add(TransactionDeleteRequested(t.id));
    }
    // The list updates from the repository stream; never remove the row here.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.currency;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionListBloc, TransactionListState>(
          listenWhen: (p, c) => p.filter.query != c.filter.query,
          listener: (context, state) {
            if (_searchController.text != state.filter.query) {
              _searchController.text = state.filter.query;
            }
          },
        ),
        BlocListener<TransactionListBloc, TransactionListState>(
          listenWhen: (p, c) =>
              c.actionError != null && p.actionError != c.actionError,
          listener: (context, state) {
            showAppSnackBar(context, state.actionError!, isError: true);
            context
                .read<TransactionListBloc>()
                .add(const TransactionListErrorDismissed());
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          actions: [
            BlocBuilder<TransactionListBloc, TransactionListState>(
              buildWhen: (p, c) =>
                  p.filter.activeFilterCount != c.filter.activeFilterCount,
              builder: (context, state) {
                final count = state.filter.activeFilterCount;
                return IconButton(
                  tooltip: 'Filters',
                  onPressed: () => showTransactionFilterSheet(context),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.tune_rounded),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(

          heroTag: 'home_add_transaction',

          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.addTransaction),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) => context
                    .read<TransactionListBloc>()
                    .add(TransactionSearchChanged(value)),
                decoration: InputDecoration(
                  hintText: 'Search by title',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<TransactionListBloc>()
                                  .add(const TransactionSearchChanged(''));
                            },
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionListBloc, TransactionListState>(
                builder: (context, state) {
                  if (state.status == TransactionListStatus.loading) {
                    return const LoadingView();
                  }
                  if (state.status == TransactionListStatus.failure) {
                    return ErrorView(
                      message: state.failure?.message ?? 'Unable to load transactions.',
                      onRetry: () => context
                          .read<TransactionListBloc>()
                          .add(const TransactionListStarted()),
                    );
                  }
                  if (!state.hasAnyTransactions) {
                    return EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No transactions yet',
                      message: 'Add your first income or expense to start tracking.',
                      actionLabel: 'Add transaction',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.addTransaction),
                    );
                  }
                  if (state.visible.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      message: 'Try a different search or clear your filters.',
                      actionLabel: 'Clear filters',
                      onAction: () => context
                          .read<TransactionListBloc>()
                          .add(const TransactionFiltersCleared()),
                    );
                  }

                  return Column(
                    children: [
                      if (state.filter.isActive)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${state.visible.length} of ${state.all.length} transactions',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context
                                    .read<TransactionListBloc>()
                                    .add(const TransactionFiltersCleared()),
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            0,
                            AppSpacing.page,
                            96,
                          ),
                          itemCount: state.visible.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final t = state.visible[index];
                            return Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirmDelete(context, t),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.xl),
                                color: theme.colorScheme.error,
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: onColorFor(theme.colorScheme.error),
                                ),
                              ),
                              child: TransactionTile(
                                transaction: t,
                                currency: currency,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.editTransaction,
                                  arguments: t.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
