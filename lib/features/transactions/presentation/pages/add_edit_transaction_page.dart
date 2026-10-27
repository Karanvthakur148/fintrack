import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/app_date_utils.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/core/utils/money.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/core/widgets/app_snackbar.dart';
import 'package:fintrack/core/widgets/confirm_dialog.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/core/widgets/loading_view.dart';
import 'package:fintrack/features/settings/presentation/settings_context.dart';
import 'package:fintrack/features/transactions/domain/entities/category.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_event.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_state.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_picker.dart';
import 'package:fintrack/features/transactions/presentation/widgets/type_toggle.dart';

/// Add / edit screen. Expects a [TransactionFormBloc] above it
/// (provided by the router).
class AddEditTransactionPage extends StatelessWidget {
  const AddEditTransactionPage({
    required this.isEditing,
    required this.initialType,
    super.key,
  });

  final bool isEditing;
  final TransactionType initialType;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionFormBloc, TransactionFormState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == TransactionFormStatus.saved) {
          showAppSnackBar(
            context,
            isEditing ? 'Transaction updated' : 'Transaction added',
          );
          Navigator.of(context).pop();
        } else if (state.status == TransactionFormStatus.deleted) {
          showAppSnackBar(context, 'Transaction deleted');
          Navigator.of(context).pop();
        } else if (state.status == TransactionFormStatus.failure) {
          showAppSnackBar(
            context,
            state.failure?.message ?? 'Something went wrong.',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        Widget body;
        if (state.status == TransactionFormStatus.loading) {
          body = const LoadingView();
        } else if (state.status == TransactionFormStatus.loadFailed) {
          body = ErrorView(
            message: state.failure?.message ?? 'Transaction not found.',
          );
        } else {
          body = TransactionForm(
            initial: state.initial,
            initialType: initialType,
            submitting: state.status == TransactionFormStatus.submitting,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit transaction' : 'Add transaction'),
            actions: [
              if (isEditing && state.initial != null)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: state.status == TransactionFormStatus.submitting
                      ? null
                      : () async {
                          final bloc = context.read<TransactionFormBloc>();
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Delete transaction?',
                            message: 'This cannot be undone.',
                            confirmLabel: 'Delete',
                            destructive: true,
                          );
                          if (confirmed) {
                            bloc.add(const TransactionFormDeleteRequested());
                          }
                        },
                ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: body,
          ),
        );
      },
    );
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    required this.initial,
    required this.initialType,
    required this.submitting,
    super.key,
  });

  final Transaction? initial;
  final TransactionType initialType;
  final bool submitting;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late TransactionType _type;
  late DateTime _date;
  String? _categoryId;
  bool _categoryMissing = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _amount = TextEditingController(
      text: initial == null ? '' : Money.toPlainString(initial.amountMinor),
    );
    _notes = TextEditingController(text: initial?.notes ?? '');
    _type = initial?.type ?? widget.initialType;
    _date = initial?.date ?? AppDateUtils.startOfDay(DateTime.now());
    _categoryId = initial?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = AppDateUtils.startOfDay(picked));
    }
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryMissing = _categoryId == null);
    final categoryId = _categoryId;
    final amount = Money.parse(_amount.text);
    if (!valid || categoryId == null || amount == null) return;

    FocusScope.of(context).unfocus();
    context.read<TransactionFormBloc>().add(
          TransactionFormSubmitted(
            title: _title.text.trim(),
            amountMinor: amount,
            categoryId: categoryId,
            type: _type,
            date: _date,
            notes: _notes.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.currency;
    final busy = widget.submitting;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          TypeToggle(
            value: _type,
            onChanged: (value) => setState(() {
              _type = value;
              // Categories are type-specific.
              _categoryId = null;
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _amount,
            enabled: !busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: theme.textTheme.headlineMedium,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '${currency.symbol} ',
            ),
            validator: Validators.amount,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _title,
            enabled: !busy,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: Validators.title,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          CategoryPicker(
            categories: Categories.forType(_type),
            selectedId: _categoryId,
            errorText: _categoryMissing ? 'Please select a category' : null,
            onChanged: busy
                ? (_) {}
                : (id) => setState(() {
                      _categoryId = id;
                      _categoryMissing = false;
                    }),
          ),
          const SizedBox(height: AppSpacing.xl),
          InkWell(
            onTap: busy ? null : _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(AppFormats.dayMonthYear.format(_date)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _notes,
            enabled: !busy,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              alignLabelWithHint: true,
            ),
            validator: Validators.notes,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.initial == null ? 'Save' : 'Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
