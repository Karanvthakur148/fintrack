import 'package:equatable/equatable.dart';

/// Income / expense totals in minor units. Balance is always derived.
class FinancialSummary extends Equatable {
  const FinancialSummary({required this.incomeMinor, required this.expenseMinor});

  static const FinancialSummary empty =
      FinancialSummary(incomeMinor: 0, expenseMinor: 0);

  final int incomeMinor;
  final int expenseMinor;

  int get balanceMinor => incomeMinor - expenseMinor;

  @override
  List<Object?> get props => [incomeMinor, expenseMinor];
}
