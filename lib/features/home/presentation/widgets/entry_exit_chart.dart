import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/month_chart_label.dart';
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

class EntryExitChart extends StatefulWidget {
  const EntryExitChart({super.key});

  @override
  State<EntryExitChart> createState() => _EntryExitChartState();
}

class _EntryExitChartState extends State<EntryExitChart> {
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

  List<_EntryExitData> _computeEntryExit(List<model.Transaction> transactions) {
    if (transactions.isEmpty) return [];

    Map<String, Map<String, double>> monthlyData = {};

    for (final t in transactions) {
      final affects = TransactionDatePolicy.transactionAffectsBalanceNow(t);
      if (!affects) continue;

      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => {'entry': 0, 'exit': 0});

      if (t.type == model.TransactionType.credit) {
        monthlyData[monthKey]!['entry'] =
            (monthlyData[monthKey]!['entry'] ?? 0) + t.value;
      } else {
        monthlyData[monthKey]!['exit'] =
            (monthlyData[monthKey]!['exit'] ?? 0) + t.value;
      }
    }

    final entries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final lastTwelve = entries.length <= 12
        ? entries
        : entries.sublist(entries.length - 12);

    return lastTwelve
        .map(
          (e) => _EntryExitData(
            monthKeyToShortLabel(e.key),
            e.value['entry'] ?? 0,
            e.value['exit'] ?? 0,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final chartData = _computeEntryExit(provider.transactions);
    if (provider.isLoading) {
      return AppCardContainer(
        title: 'Entradas e Saídas',
        child: const Center(child: Text('Carregando...')),
      );
    }
    return AppCardContainer(
      title: 'Entradas e Saídas',
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
        legend: Legend(isVisible: true),
        tooltipBehavior: brlCartesianTooltipBehavior(),
        series: <CartesianSeries<_EntryExitData, String>>[
          ColumnSeries<_EntryExitData, String>(
            dataSource: chartData,
            xValueMapper: (_EntryExitData item, _) => item.month,
            yValueMapper: (_EntryExitData item, _) => item.entry,
            dataLabelMapper: (_EntryExitData item, _) =>
                formatReaisToBRL(item.entry),
            name: 'Entrada',
            color: AppDesignTokens.colorFeedbackSuccess,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          ColumnSeries<_EntryExitData, String>(
            dataSource: chartData,
            xValueMapper: (_EntryExitData item, _) => item.month,
            yValueMapper: (_EntryExitData item, _) => item.exit,
            dataLabelMapper: (_EntryExitData item, _) =>
                formatReaisToBRL(item.exit),
            name: 'Saída',
            color: AppDesignTokens.colorFeedbackError,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _EntryExitData {
  _EntryExitData(this.month, this.entry, this.exit);

  final String month;
  final double entry;
  final double exit;
}
