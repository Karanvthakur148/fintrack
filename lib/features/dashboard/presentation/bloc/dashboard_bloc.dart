import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/dashboard/domain/usecases/build_dashboard_data.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';

/// Rebuilds the dashboard every time the shared transaction stream emits.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required WatchTransactions watchTransactions,
    required BuildDashboardData buildDashboardData,
    DateTime Function()? clock,
  })  : _watch = watchTransactions,
        _build = buildDashboardData,
        _clock = clock ?? DateTime.now,
        super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
  }

  final WatchTransactions _watch;
  final BuildDashboardData _build;
  final DateTime Function() _clock;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardState());
    await emit.forEach<List<Transaction>>(
      _watch(),
      onData: (transactions) => DashboardState(
        status: DashboardStatus.success,
        data: _build(transactions, _clock()),
      ),
      onError: (error, _) => DashboardState(
        status: DashboardStatus.failure,
        failure: failureFrom(error),
      ),
    );
  }
}
