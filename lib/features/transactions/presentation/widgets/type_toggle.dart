import 'package:flutter/material.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';

/// Expense / Income switch.
class TypeToggle extends StatelessWidget {
  const TypeToggle({required this.value, required this.onChanged, super.key});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.arrow_upward_rounded),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Income'),
          icon: Icon(Icons.arrow_downward_rounded),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
