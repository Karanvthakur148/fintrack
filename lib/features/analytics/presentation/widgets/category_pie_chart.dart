import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_entities.dart';
import 'package:fintrack/features/analytics/presentation/widgets/chart_placeholder.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_visuals.dart';

/// Donut chart of expense distribution by category.
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({required this.data, super.key});

  final List<CategoryAmount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const ChartPlaceholder(message: 'No expenses in this period');
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 44,
          sections: [
            for (final item in data)
              PieChartSectionData(
                value: item.amountMinor / 100,
                color: CategoryVisuals.of(item.categoryId).color,
                radius: 54,
                title: item.share >= 0.08
                    ? '${(item.share * 100).round()}%'
                    : '',
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
