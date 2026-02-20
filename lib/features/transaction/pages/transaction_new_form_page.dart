import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';
// Ao descomentar checagem de auth em _onSubmit/initState: adicione import auth_provider
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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  model.TransactionType _type = model.TransactionType.expense;

  @override
  void initState() {
    super.initState();
    // Com login obrigatório: redirecionar para login se não autenticado
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final auth = context.read<AuthProvider>();
    //   if (!auth.isAuthenticated) {
    //     Navigator.of(context).pushReplacementNamed('/login');
    //   }
    // });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final err = requiredField(value);
    if (err != null) return err;
    final parsed = int.tryParse(value!.replaceAll(RegExp(r'[^\d-]'), ''));
    if (parsed == null) return 'Valor inválido';
    return null;
  }

  int _parseAmountCents() {
    final s = _amountController.text.trim().replaceAll(',', '.');
    final num? n = num.tryParse(s);
    if (n == null) return 0;
    return (n * 100).round();
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
    // Com login obrigatório: exigir autenticação para criar transação
    // final auth = context.read<AuthProvider>();
    // if (!auth.isAuthenticated) return;
    final transaction = model.Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amountCents: _parseAmountCents(),
      type: _type,
      date: _date,
    );
    final ok = await context.read<TransactionsProvider>().addTransaction(transaction);
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Título',
                    controller: _titleController,
                    validator: requiredField,
                  ),
                  const SizedBox(height: AppDesignTokens.spacingMd),
                  AppTextField(
                    label: 'Valor (ex: 100 ou 99,50)',
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: AppDesignTokens.spacingMd),
                  SegmentedButton<model.TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: model.TransactionType.income,
                        label: Text('Receita'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: model.TransactionType.expense,
                        label: Text('Despesa'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
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
                  if (context.watch<TransactionsProvider>().errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDesignTokens.spacingMd),
                      child: Text(
                        context.watch<TransactionsProvider>().errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
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
