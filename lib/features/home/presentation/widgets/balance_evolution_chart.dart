import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/month_chart_label.dart'
    show monthKeyToShortLabel, prevMonthKey;
import 'package:cortex_bank_mobile/core/utils/syncfusion_brl_tooltip.dart';
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
  List<_BalanceEvolutionData> _computeEvolution(
    List<model.Transaction> transactions,
  ) {
    if (transactions.isEmpty) return [];

    final sorted = List<model.Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double balance = 0;
    final monthlyBalance = <String, double>{};

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

    final lastFive = entries.length <= 5
        ? entries
        : entries.sublist(entries.length - 5);

    if (lastFive.isEmpty) return [];

    final firstKey = lastFive.first.key;
    final firstParts = firstKey.split('-');
    if (firstParts.length != 2) {
      return lastFive
          .map(
            (e) => _BalanceEvolutionData(monthKeyToShortLabel(e.key), e.value),
          )
          .toList();
    }
    final firstY = int.tryParse(firstParts[0]);
    final firstM = int.tryParse(firstParts[1]);
    if (firstY == null || firstM == null) {
      return lastFive
          .map(
            (e) => _BalanceEvolutionData(monthKeyToShortLabel(e.key), e.value),
          )
          .toList();
    }

    final startOfFirstMonth = DateTime(firstY, firstM, 1);
    double openingBalance = 0;
    for (final t in sorted) {
      final d = TransactionDatePolicy.dateOnly(t.date);
      if (!d.isBefore(startOfFirstMonth)) break;
      if (TransactionDatePolicy.transactionAffectsBalanceNow(t)) {
        openingBalance += t.type == model.TransactionType.credit
            ? t.value
            : -t.value;
      }
    }

    return [
      _BalanceEvolutionData(
        monthKeyToShortLabel(prevMonthKey(firstKey)),
        openingBalance,
      ),
      ...lastFive.map(
        (e) => _BalanceEvolutionData(monthKeyToShortLabel(e.key), e.value),
      ),
    ];
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
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: chartAxisBrlNumberFormat,
          labelRotation: -45,
          axisLine: const AxisLine(width: 0),
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppDesignTokens.colorGray200,
          ),
        ),
        legend: Legend(isVisible: false),
        tooltipBehavior: brlCartesianTooltipBehavior(),
        series: <CartesianSeries<_BalanceEvolutionData, String>>[
          LineSeries<_BalanceEvolutionData, String>(
            dataSource: chartData,
            xValueMapper: (_BalanceEvolutionData balance, _) => balance.month,
            yValueMapper: (_BalanceEvolutionData balance, _) => balance.amount,
            dataLabelMapper: (_BalanceEvolutionData balance, _) =>
                formatReaisToBRL(balance.amount),
            name: 'Saldo',
            width: 3,
            color: AppDesignTokens.colorPrimary,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              borderWidth: 2,
            ),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.shift,
            ),
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
