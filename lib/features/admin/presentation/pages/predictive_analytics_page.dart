import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

class PredictiveAnalyticsPage extends StatelessWidget {
  const PredictiveAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Analytics'),
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          _buildForecastCard(
            context,
            'User Growth',
            '+15% next week',
            Icons.trending_up_rounded,
            AppColors.success,
          ),
          _buildForecastCard(
            context,
            'Revenue',
            'RM 50k next month',
            Icons.attach_money_rounded,
            AppColors.primary,
          ),
          _buildForecastCard(
            context,
            'At-Risk Users',
            '120 users flagged',
            Icons.warning_rounded,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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


