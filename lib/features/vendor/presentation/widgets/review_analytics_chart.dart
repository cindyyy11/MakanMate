import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/analytics_entity.dart';

class ReviewAnalyticsChart extends StatelessWidget {
  final ReviewAnalyticsEntity? analytics;
  final bool isWeekly;
  final VoidCallback? onToggleView;

  const ReviewAnalyticsChart({
    super.key,
    required this.analytics,
    required this.isWeekly,
    this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    if (analytics == null || analytics!.dataPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No review data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Avg: ${analytics!.overallAverage.toStringAsFixed(1)} ⭐ | Total: ${analytics!.totalReviews}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        label: 'Weekly',
                        isSelected: isWeekly,
                        onTap: isWeekly ? null : onToggleView,
                      ),
                      _buildToggleButton(
                        label: 'Monthly',
                        isSelected: !isWeekly,
                        onTap: !isWeekly ? null : onToggleView,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart - Using SizedBox instead of Expanded
            SizedBox(
              height: 280,
              child: LineChart(
                _buildChartData(),
              ),
            ),
            const SizedBox(height: 24),
            // Average Rating Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Average Rating: ${analytics!.overallAverage.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Rating Distribution
            Text(
              'Rating Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ..._buildRatingDistribution(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRatingDistribution() {
    if (analytics == null || analytics!.ratingDistribution.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No rating distribution data available',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ];
    }

    final totalReviews = analytics!.totalReviews;
    if (totalReviews == 0) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No reviews yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ];
    }

    return [5, 4, 3, 2, 1].map((rating) {
      final count = analytics!.ratingDistribution[rating] ?? 0;
      final percentage = totalReviews > 0 ? (count / totalReviews) * 100 : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            // Star rating label
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, size: 16, color: Colors.orange),
                ],
              ),
            ),
            // Progress bar
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage / 100,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Count and percentage
            SizedBox(
              width: 80,
              child: Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final spots = analytics!.dataPoints.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final dataPoint = entry.value;
      return FlSpot(index, dataPoint.averageRating);
    }).toList();

    final minY = spots.isEmpty
        ? 0.0
        : (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9).clamp(0.0, 5.0);
    final maxY = 5.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= analytics!.dataPoints.length) {
                return const Text('');
              }
              final dataPoint = analytics!.dataPoints[value.toInt()];
              if (isWeekly) {
                return Text(
                  DateFormat('EEE').format(dataPoint.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              } else {
                return Text(
                  'W${_getWeekNumber(dataPoint.date)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: (analytics!.dataPoints.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.orange,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final dataPoint = analytics!.dataPoints[spot.x.toInt()];
              return LineTooltipItem(
                '${dataPoint.averageRating.toStringAsFixed(1)} ⭐\n${dataPoint.reviewCount} reviews',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }
}