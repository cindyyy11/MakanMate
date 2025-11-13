import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

class PerformanceMonitoringPage extends StatelessWidget {
  const PerformanceMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitoring'),
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          _buildMetricCard(
            context,
            'Avg API Response',
            '245ms',
            Icons.speed_rounded,
            AppColors.success,
          ),
          _buildMetricCard(
            context,
            'Slow Queries',
            '3',
            Icons.warning_rounded,
            AppColors.warning,
          ),
          _buildMetricCard(
            context,
            'Database Size',
            '2.3GB',
            Icons.storage_rounded,
            AppColors.info,
          ),
          _buildMetricCard(
            context,
            'Cache Hit Rate',
            '87%',
            Icons.cached_rounded,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      child: Padding(
        padding: UIConstants.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


