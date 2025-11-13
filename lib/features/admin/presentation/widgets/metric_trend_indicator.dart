import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';

/// Trend indicator showing increase/decrease with percentage
class MetricTrendIndicator extends StatelessWidget {
  final double percentage;
  final bool isPositive;
  final String label;

  const MetricTrendIndicator({
    super.key,
    required this.percentage,
    required this.isPositive,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.success : AppColors.error).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: UIConstants.fontSizeXs,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontSizeXs,
              color: AppColorsExtension.getGrey600(context),
            ),
          ),
        ],
      ),
    );
  }
}

