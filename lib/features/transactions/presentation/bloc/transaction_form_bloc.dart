import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/add_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/get_transaction_by_id.dart';
import 'package:fintrack/features/transactions/domain/usecases/update_transaction.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_state.dart';
import 'package:uuid/uuid.dart';

/// Handles adding, editing and deleting a single transaction.
class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  TransactionFormBloc({
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required GetTransactionById getTransactionById,
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  })  : _add = addTransaction,
        _update = updateTransaction,
        _delete = deleteTransaction,
        _getById = getTransactionById,
        _uuid = uuid,
        _clock = clock ?? DateTime.now,
        super(const TransactionFormState()) {
    on<TransactionFormStarted>(_onStarted);
    on<TransactionFormSubmitted>(_onSubmitted);
    on<TransactionFormDeleteRequested>(_onDelete);
  }

  final AddTransaction _add;
  final UpdateTransaction _update;
  final DeleteTransaction _delete;
  final GetTransactionById _getById;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> _onStarted(
    TransactionFormStarted event,
    Emitter<TransactionFormState> emit,
  ) async {
    final id = event.transactionId;
    if (id == null) {
      emit(state.copyWith(status: TransactionFormStatus.ready));
      return;
    }
    emit(state.copyWith(status: TransactionFormStatus.loading));
    try {
      final transaction = await _getById(id);
      emit(state.copyWith(
        status: TransactionFormStatus.ready,
        initial: transaction,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: TransactionFormStatus.loadFailed,
        failure: failureFrom(error),
      ));
    }
  }

  Future<void> _onSubmitted(
    TransactionFormSubmitted event,
    Emitter<TransactionFormState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionFormStatus.submitting,
      clearFailure: true,
    ));
    try {
      final now = _clock();
      final existing = state.initial;
      final notes = event.notes?.trim();
      final transaction = Transaction(
        id: existing?.id ?? _uuid.v4(),
        title: event.title.trim(),
        amountMinor: event.amountMinor,
        categoryId: event.categoryId,
        type: event.type,
        date: event.date,
        notes: (notes == null || notes.isEmpty) ? null : notes,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      if (existing == null) {
        await _add(transaction);
      } else {
        await _update(transaction);
      }
      emit(state.copyWith(status: TransactionFormStatus.saved));
    } catch (error) {
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        failure: failureFrom(error),
      ));
    }
  }

  Future<void> _onDelete(
    TransactionFormDeleteRequested event,
    Emitter<TransactionFormState> emit,
  ) async {
    final id = state.initial?.id;
    if (id == null) return;
    emit(state.copyWith(
      status: TransactionFormStatus.submitting,
      clearFailure: true,
    ));
    try {
      await _delete(id);
      emit(state.copyWith(status: TransactionFormStatus.deleted));
    } catch (error) {
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        failure: failureFrom(error),
      ));
    }
  }
}
