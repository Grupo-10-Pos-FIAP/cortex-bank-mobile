import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalanceEvolutionChart extends StatelessWidget {
  const BalanceEvolutionChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_BalanceEvolutionData> data = [
      _BalanceEvolutionData('Jan', 1200),
      _BalanceEvolutionData('Feb', 1350),
      _BalanceEvolutionData('Mar', 1280),
      _BalanceEvolutionData('Apr', 1420),
      _BalanceEvolutionData('May', 1500),
    ];
    return AppCardContainer(
      title: 'Evolução do Saldo', 
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_BalanceEvolutionData, String>>[
          LineSeries<_BalanceEvolutionData, String>(
            dataSource: data,
            xValueMapper: (_BalanceEvolutionData balance, _) => balance.month,
            yValueMapper: (_BalanceEvolutionData balance, _) => balance.amount,
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
