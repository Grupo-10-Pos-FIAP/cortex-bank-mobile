import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;

class BalanceEvolutionChart extends StatefulWidget {
  const BalanceEvolutionChart({super.key});

  @override
  State<BalanceEvolutionChart> createState() => _BalanceEvolutionChartState();
}

class _BalanceEvolutionChartState extends State<BalanceEvolutionChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<TransactionsProvider>();
    await provider.loadTransactions();
  }

  List<_BalanceEvolutionData> _computeEvolution(
    List<model.Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    final sorted = List<model.Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double balance = 0;
    Map<String, double> monthlyBalance = {};

    for (final t in sorted) {
      if (TransactionDatePolicy.transactionAffectsBalanceNow(t)) {
        balance += t.type == model.TransactionType.credit ? t.value : -t.value;
      }
      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthlyBalance[monthKey] = balance;
    }

    final entries = monthlyBalance.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .take(5)
        .map((e) => _BalanceEvolutionData(e.key, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final chartData = _computeEvolution(provider.transactions);
    if (provider.isLoading) {
      return AppCardContainer(
        title: 'Evolução do Saldo',
        child: const Center(child: Text('Carregando...')),
      );
    }
    return AppCardContainer(
      title: 'Evolução do Saldo',
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_BalanceEvolutionData, String>>[
          LineSeries<_BalanceEvolutionData, String>(
            dataSource: chartData,
            xValueMapper: (_BalanceEvolutionData balance, _) => balance.month,
            yValueMapper: (_BalanceEvolutionData balance, _) => balance.amount,
            dataLabelMapper: (_BalanceEvolutionData balance, _) =>
                formatCentsToBRLWithThousands(
                  (balance.amount * 100).round(),
                ),
            name: 'Saldo',
            color: AppDesignTokens.colorPrimary,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _BalanceEvolutionData {
  _BalanceEvolutionData(this.month, this.amount);

  final String month;
  final double amount;
}
