/// Whether a transaction adds to or subtracts from the balance.
/// Amounts are always stored positive; the type carries the direction.
enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;

  String get label => isIncome ? 'Income' : 'Expense';
}
