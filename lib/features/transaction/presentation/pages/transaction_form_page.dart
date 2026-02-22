import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
// Ao descomentar checagem de auth em _onSubmit/initState: adicione import auth_provider
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
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
      body: SafeArea(child: Center(child: Text("Transaction Page"))),
    );
  }
}
