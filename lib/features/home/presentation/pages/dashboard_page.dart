import 'package:cortex_bank_mobile/features/home/presentation/widgets/entry_exit_chart.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/home/presentation/widgets/balance_evolution_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadBalanceSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return SingleChildScrollView(
      child: Column(
        children: [
          AppBalanceCard(
            mostrarSaldoInicial: true,
          ),
          const BalanceEvolutionChart(),
          const EntryExitChart(),
        ],
      ),
    );
  }
}
