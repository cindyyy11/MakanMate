import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

/// Widget for displaying metric trend chart
class TrendChartWidget extends StatelessWidget {
  final MetricTrend trend;
  final Color lineColor;
  final String title;

  const TrendChartWidget({
    super.key,
    required this.trend,
    required this.lineColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (trend.dataPoints.isEmpty) {
      return GlassContainer(
        height: 200,
        padding: UIConstants.paddingLg,
        borderRadius: UIConstants.borderRadiusLg,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: AppColorsExtension.getGrey600(context),
            ),
          ),
        ),
      );
    }

    return GlassContainer(
      padding: UIConstants.paddingLg,
      borderRadius: UIConstants.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
              _buildChangeIndicator(),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMd),
          SizedBox(
            height: 200,
            child: LineChart(
              _buildChartData(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator() {
    final isPositive = trend.isIncreasing;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '${trend.percentageChange.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: UIConstants.fontSizeSm,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = trend.dataPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.grey300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateLabelInterval(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < trend.dataPoints.length) {
                final date = trend.dataPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM dd').format(date),
                    style: TextStyle(
                      color: AppColorsExtension.getGrey600(context),
                      fontSize: UIConstants.fontSizeXs,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: AppColorsExtension.getGrey600(context),
                  fontSize: UIConstants.fontSizeXs,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.grey300,
        ),
      ),
      minX: 0,
      maxX: (trend.dataPoints.length - 1).toDouble(),
      minY: 0,
      maxY: _calculateMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  double _calculateMaxY() {
    if (trend.dataPoints.isEmpty) return 100;
    final maxValue = trend.dataPoints
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble(); // Add 20% padding
  }

  double _calculateInterval() {
    final maxY = _calculateMaxY();
    return maxY / 5; // 5 horizontal lines
  }

  double _calculateLabelInterval() {
    final length = trend.dataPoints.length;
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    return (length / 7).ceilToDouble();
  }
}

