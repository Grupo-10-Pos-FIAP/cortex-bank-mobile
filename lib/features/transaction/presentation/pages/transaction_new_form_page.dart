import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';

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
  model.TransactionCategory _category = model.TransactionCategory.others;

  @override
  void dispose() {
    _amountController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  double _parseValueReais() {
    final s = _amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;

    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final value = _parseValueReais();

    final transaction = model.Transaction(
      id: '',
      accountId: user.uid,
      type: _type,
      category: _category,
      value: value,
      date: _date,
      from: _fromController.text.trim().isEmpty
          ? null
          : _fromController.text.trim(),
      to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
      status: 'Pending',
    );

    final ok = await context.read<TransactionsProvider>().addTransaction(
      transaction,
    );

    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionsProvider>();

    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
          child: AppCardContainer(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Valor (R\$)',
                    controller: _amountController,
                    hintText: '0,00',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyBRLInputFormatter(),
                    ],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        requiredField(v) ??
                        (_parseValueReais() <= 0 ? 'Valor inválido' : null),
                  ),
                  const SizedBox(height: AppDesignTokens.spacingMd),

                  // Origem/Destino
                  AppTextField(
                    label: 'Origem (Opcional)',
                    controller: _fromController,
                  ),
                  const SizedBox(height: AppDesignTokens.spacingSm),
                  AppTextField(
                    label: 'Destino (Opcional)',
                    controller: _toController,
                  ),
                  const SizedBox(height: AppDesignTokens.spacingMd),

                  // Seletor de Tipo
                  SegmentedButton<model.TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: model.TransactionType.credit,
                        label: Text('Crédito'),
                      ),
                      ButtonSegment(
                        value: model.TransactionType.debit,
                        label: Text('Débito'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),

                  SegmentedButton<model.TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: model.TransactionType.credit,
                        label: Text('Crédito'),
                        icon: Icon(
                          Icons.add_circle_outline,
                        ), // Opcional: ícone de entrada
                      ),
                      ButtonSegment(
                        value: model.TransactionType.debit,
                        label: Text('Débito'),
                        icon: Icon(
                          Icons.remove_circle_outline,
                        ), // Opcional: ícone de saída
                      ),
                      ButtonSegment(
                        value: model.TransactionType.ted,
                        label: Text('TED'),
                        icon: Icon(
                          Icons.sync_alt,
                        ), // Opcional: ícone de transferência
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),


                  const SizedBox(height: AppDesignTokens.spacingMd),

                  // Seletor de Data
                  ListTile(
                    title: const Text('Data da transação'),
                    subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: AppDesignTokens.colorBgDefault,
                    onTap: _pickDate,
                  ),

                  const SizedBox(height: AppDesignTokens.spacingLg),

                  AppButton(
                    label: 'Salvar Transação',
                    loading: txProvider.isLoading,
                    onPressed: _onSubmit,
                  ),

                  if (txProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDesignTokens.spacingMd,
                      ),
                      child: Text(
                        txProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
