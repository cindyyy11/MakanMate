import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';
import 'package:fl_chart/fl_chart.dart';

/// Fairness Dashboard Widget
/// 
/// Displays AI recommendation fairness metrics including:
/// - Cuisine distribution pie chart
/// - Small vendor visibility
/// - Bias alerts
/// - Diversity score
/// - NDCG score
class FairnessDashboardWidget extends StatelessWidget {
  const FairnessDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoaded && state.fairnessMetrics != null) {
          return _buildDashboard(context, state.fairnessMetrics!);
        } else if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Load fairness metrics if not loaded
          context.read<AdminBloc>().add(const LoadFairnessMetrics());
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildDashboard(BuildContext context, FairnessMetrics metrics) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const RefreshFairnessMetrics());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Recommendation Fairness',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AdminBloc>().add(const RefreshFairnessMetrics());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDateTime(metrics.calculatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics Cards
            _buildKeyMetricsRow(context, metrics),
            const SizedBox(height: 24),

            // Cuisine Distribution Chart
            _buildCuisineChart(context, metrics),
            const SizedBox(height: 24),

            // Vendor Size Visibility
            _buildVendorVisibility(context, metrics),
            const SizedBox(height: 24),

            // Bias Alerts
            if (metrics.biasAlerts.isNotEmpty) ...[
              _buildBiasAlerts(context, metrics.biasAlerts),
              const SizedBox(height: 24),
            ],

            // Analysis Info
            _buildAnalysisInfo(context, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsRow(BuildContext context, FairnessMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Diversity Score',
            '${(metrics.diversityScore * 100).toStringAsFixed(1)}%',
            _getDiversityColor(metrics.diversityScore),
            Icons.diversity_3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'NDCG Score',
            metrics.ndcgScore.toStringAsFixed(3),
            _getNDCGColor(metrics.ndcgScore),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Analyzed',
            '${metrics.totalRecommendations}',
            Colors.blue,
            Icons.analytics,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineChart(BuildContext context, FairnessMetrics metrics) {
    if (metrics.cuisineDistribution.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('No cuisine distribution data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuisine Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(metrics.cuisineDistribution),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCuisineLegend(metrics.cuisineDistribution),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> distribution,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    int colorIndex = 0;
    return distribution.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCuisineLegend(Map<String, double> distribution) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    int colorIndex = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: distribution.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildVendorVisibility(
    BuildContext context,
    FairnessMetrics metrics,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor Size Visibility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVendorBar(
                    'Small Vendors',
                    metrics.smallVendorVisibility,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVendorBar(
                    'Large Vendors',
                    metrics.largeVendorVisibility,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiasAlerts(BuildContext context, List<BiasAlert> alerts) {
    return Card(
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Bias Alerts (${alerts.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map((alert) => _buildBiasAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildBiasAlertItem(BiasAlert alert) {
    Color severityColor;
    IconData severityIcon;
    switch (alert.severity) {
      case BiasSeverity.high:
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case BiasSeverity.medium:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case BiasSeverity.low:
        severityColor = Colors.yellow[700]!;
        severityIcon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(severityIcon, color: severityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.recommendation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInfo(BuildContext context, FairnessMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Analysis Period',
              '${_formatDate(metrics.analysisStartDate)} - ${_formatDate(metrics.analysisEndDate)}',
            ),
            _buildInfoRow(
              'Total Recommendations',
              '${metrics.totalRecommendations}',
            ),
            _buildInfoRow(
              'Calculated At',
              _formatDateTime(metrics.calculatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDiversityColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getNDCGColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}


