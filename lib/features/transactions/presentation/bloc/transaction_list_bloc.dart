import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_filter.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/filter_transactions.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_state.dart';

/// Drives the All Transactions screen. Subscribes to the shared repository
/// stream, so every add / edit / delete anywhere updates this list.
class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  TransactionListBloc({
    required WatchTransactions watchTransactions,
    required DeleteTransaction deleteTransaction,
    required FilterTransactions filterTransactions,
  })  : _watch = watchTransactions,
        _delete = deleteTransaction,
        _filter = filterTransactions,
        super(const TransactionListState()) {
    on<TransactionListStarted>(_onStarted);
    on<TransactionSearchChanged>(
      (e, emit) => _applyFilter(emit, state.filter.withQuery(e.query)),
    );
    on<TransactionTypeFilterChanged>(
      (e, emit) => _applyFilter(emit, state.filter.withType(e.type)),
    );
    on<TransactionCategoryFilterChanged>(
      (e, emit) => _applyFilter(emit, state.filter.withCategory(e.categoryId)),
    );
    on<TransactionDateRangeChanged>(
      (e, emit) =>
          _applyFilter(emit, state.filter.withRange(from: e.from, to: e.to)),
    );
    on<TransactionSortChanged>(
      (e, emit) => _applyFilter(emit, state.filter.withSort(e.sort)),
    );
    on<TransactionFiltersCleared>(
      (e, emit) => _applyFilter(emit, const TransactionFilter()),
    );
    on<TransactionDeleteRequested>(_onDelete);
    on<TransactionListErrorDismissed>(
      (e, emit) => emit(state.copyWith(clearActionError: true)),
    );
  }

  final WatchTransactions _watch;
  final DeleteTransaction _delete;
  final FilterTransactions _filter;

  Future<void> _onStarted(
    TransactionListStarted event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionListStatus.loading,
      clearFailure: true,
    ));
    await emit.forEach<List<Transaction>>(
      _watch(),
      onData: (transactions) => state.copyWith(
        status: TransactionListStatus.success,
        all: transactions,
        visible: _filter(transactions, state.filter),
        clearFailure: true,
      ),
      onError: (error, _) => state.copyWith(
        status: TransactionListStatus.failure,
        failure: failureFrom(error),
      ),
    );
  }

  void _applyFilter(
    Emitter<TransactionListState> emit,
    TransactionFilter filter,
  ) {
    emit(state.copyWith(
      filter: filter,
      visible: _filter(state.all, filter),
    ));
  }

  Future<void> _onDelete(
    TransactionDeleteRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    try {
      await _delete(event.id);
    } catch (error) {
      emit(state.copyWith(actionError: failureFrom(error).message));
    }
  }
}
