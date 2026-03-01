import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EntryExitChart extends StatelessWidget {
  const EntryExitChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_EntryExitData> data = [
      _EntryExitData('Jan', 800, 400),
      _EntryExitData('Feb', 900, 550),
      _EntryExitData('Mar', 700, 600),
      _EntryExitData('Apr', 1200, 780),
      _EntryExitData('May', 1100, 900),
    ];
    return AppCardContainer(
      title: 'Entradas e Saídas',
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        legend: Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_EntryExitData, String>>[
          ColumnSeries<_EntryExitData, String>(
            dataSource: data,
            xValueMapper: (_EntryExitData item, _) => item.month,
            yValueMapper: (_EntryExitData item, _) => item.entry,
            name: 'Entrada',
            color: AppDesignTokens.colorFeedbackSuccess,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          ColumnSeries<_EntryExitData, String>(
            dataSource: data,
            xValueMapper: (_EntryExitData item, _) => item.month,
            yValueMapper: (_EntryExitData item, _) => item.exit,
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
