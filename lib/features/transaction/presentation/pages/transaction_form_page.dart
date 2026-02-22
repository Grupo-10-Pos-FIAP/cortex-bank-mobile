import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_new_transaction_card.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:provider/provider.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionsProvider>();
    final saldoReal = (txProvider.balanceSummary?.totalIncomeCents ?? 0) / 100;

    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBalanceCard(saldo: saldoReal),
              const AppNewTransactionCard(),
            ],
          ),
        ),
      ),
    );
  }
}
