import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_new_transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadBalanceSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBalanceCard(),
              const AppNewTransactionCard(),
            ],
          ),
        ),
      ),
    );
  }
}
