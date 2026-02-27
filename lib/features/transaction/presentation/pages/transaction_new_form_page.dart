import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';

/// accountId fixo até integrar com conta autenticada.
const String _defaultAccountId = 'mobile-default';

class TransactionNewFormPage extends StatefulWidget {
  const TransactionNewFormPage({super.key});

  @override
  State<TransactionNewFormPage> createState() => _TransactionNewFormPageState();
}

class _TransactionNewFormPageState extends State<TransactionNewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime _date = DateTime.now();
  model.TransactionType _type = model.TransactionType.debit;

  @override
  void dispose() {
    _amountController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final err = requiredField(value);
    if (err != null) return err;
    final s = value!.trim().replaceAll(',', '.');
    final n = num.tryParse(s);
    if (n == null || n < 0) return 'Valor inválido';
    return null;
  }

  /// Valor em reais (double).
  double _parseValueReais() {
    final s = _amountController.text.trim().replaceAll(',', '.');
    final n = num.tryParse(s);
    if (n == null) return 0;
    return n.toDouble();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    final value = _parseValueReais();
    if (value <= 0) return;
    final transaction = model.Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      accountId: _defaultAccountId,
      type: _type,
      value: value,
      date: _date,
      from: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
      to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
      status: 'Pending',
    );
    final ok = await context.read<TransactionsProvider>().addTransaction(
      transaction,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
          child: AppCardContainer(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nova transação',
                      style: GoogleFonts.roboto(
                        fontSize: AppDesignTokens.fontSizeTitle,
                        fontWeight: AppDesignTokens.fontWeightSemibold,
                        color: AppDesignTokens.colorContentDefault,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: 'Valor em reais (ex: 100 ou 99,50)',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMd),
                    AppTextField(
                      label: 'De (origem)',
                      controller: _fromController,
                    ),
                    const SizedBox(height: AppDesignTokens.spacingSm),
                    AppTextField(
                      label: 'Para (destino)',
                      controller: _toController,
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMd),
                    SegmentedButton<model.TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: model.TransactionType.credit,
                          label: Text('Crédito'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: model.TransactionType.debit,
                          label: Text('Débito'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) =>
                          setState(() => _type = s.first),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMd),
                    ListTile(
                      title: const Text('Data'),
                      subtitle: Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AppDesignTokens.spacingLg),
                    Consumer<TransactionsProvider>(
                      builder: (context, tx, _) {
                        return AppButton(
                          label: 'Salvar',
                          loading: tx.loading,
                          onPressed: _onSubmit,
                        );
                      },
                    ),
                    if (context.watch<TransactionsProvider>().errorMessage !=
                        null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppDesignTokens.spacingMd,
                        ),
                        child: Text(
                          context.watch<TransactionsProvider>().errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
