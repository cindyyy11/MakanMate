import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

/// Card widget for displaying a single metric
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: UIConstants.borderRadiusLg,
        child: Container(
          padding: UIConstants.paddingLg,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface,
            borderRadius: UIConstants.borderRadiusLg,
            gradient: backgroundColor != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      backgroundColor!.withValues(alpha: 0.8),
                      backgroundColor!.withValues(alpha: 0.6),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: UIConstants.iconSizeXl,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: UIConstants.iconSizeSm,
                      color: AppColors.grey600,
                    ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey700,
                  fontSize: UIConstants.fontSizeMd,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: UIConstants.fontSize3Xl,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                    fontSize: UIConstants.fontSizeSm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
