import 'package:equatable/equatable.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/dashboard/domain/entities/dashboard_data.dart';

enum DashboardStatus { loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.data,
    this.failure,
  });

  final DashboardStatus status;
  final DashboardData? data;
  final Failure? failure;

  @override
  List<Object?> get props => [status, data, failure];
}
