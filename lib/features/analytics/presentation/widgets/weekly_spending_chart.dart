import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:fintrack/core/utils/date_formatters.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/analytics/presentation/widgets/chart_placeholder.dart';

/// Bar chart of daily expenses for one week.
class WeeklySpendingChart extends StatelessWidget {
  const WeeklySpendingChart({
    required this.data,
    required this.currency,
    super.key,
  });

  final List<DailyAmount> data;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((d) => d.amountMinor > 0);
    if (!hasData) {
      return const ChartPlaceholder(message: 'No spending recorded this week');
    }

    final scheme = Theme.of(context).colorScheme;
    final colors = context.finColors;
    final maxMinor = data.map((d) => d.amountMinor).reduce(math.max);
    final maxY = maxMinor / 100 * 1.25;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      AppFormats.weekdayShort.format(data[i].date),
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                CurrencyFormatter.format((rod.toY * 100).round(), currency),
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].amountMinor / 100,
                    width: 16,
                    color: colors.expense,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
