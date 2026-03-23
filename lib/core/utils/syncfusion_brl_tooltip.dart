import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Tooltip dos gráficos cartesianos com valores em BRL (mesma convenção do app).
TooltipBehavior brlCartesianTooltipBehavior({
  Color backgroundColor = const Color(0xFF212121),
}) {
  return TooltipBehavior(
    enable: true,
    color: backgroundColor,
    builder: (
      dynamic data,
      dynamic point,
      dynamic series,
      int pointIndex,
      int seriesIndex,
    ) {
      final p = point as ChartPoint<dynamic>?;
      if (p == null || p.y == null) return const SizedBox.shrink();
      final s = series as ChartSeries<dynamic, dynamic>;
      final xLabel = p.x?.toString() ?? '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$xLabel : ${formatReaisToBRL(p.y!.toDouble())}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    },
  );
}
