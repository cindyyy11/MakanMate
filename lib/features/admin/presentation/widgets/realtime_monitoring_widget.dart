import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/presentation/widgets/animated_metric_card.dart';
import 'package:intl/intl.dart';

/// Real-time monitoring widget
/// 
/// Displays current system metrics with real-time updates
class RealtimeMonitoringWidget extends StatelessWidget {
  final SystemMetrics? systemMetrics;

  const RealtimeMonitoringWidget({
    Key? key,
    this.systemMetrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (systemMetrics == null) {
      return Center(
        child: Padding(
          padding: UIConstants.paddingXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sensors_off_rounded,
                size: 64,
                color: AppColorsExtension.getGrey600(context),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Text(
                'No real-time data available',
                style: TextStyle(
                  color: AppColorsExtension.getGrey600(context),
                  fontSize: UIConstants.fontSizeLg,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                'Waiting for system metrics...',
                style: TextStyle(
                  color: AppColorsExtension.getGrey600(context),
                  fontSize: UIConstants.fontSizeSm,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final metrics = systemMetrics!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health Status Header
        _buildHealthStatusHeader(context, metrics),
        const SizedBox(height: UIConstants.spacingXl),

        // Real-time Metrics Cards
        _buildRealtimeMetrics(context, metrics),
        const SizedBox(height: UIConstants.spacingXl),

        // System Performance
        _buildSystemPerformance(context, metrics),
      ],
    );
  }

  Widget _buildHealthStatusHeader(BuildContext context, SystemMetrics metrics) {
    final statusColor = _getHealthStatusColor(metrics.healthStatus);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return GlassContainer(
      padding: UIConstants.paddingLg,
      borderRadius: UIConstants.borderRadiusLg,
      borderColor: statusColor.withValues(alpha: 0.3),
      borderWidth: 2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              _getHealthStatusEmoji(metrics.healthStatus),
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: UIConstants.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColorsExtension.getTextSecondary(context),
                        fontSize: UIConstants.fontSizeSm,
                      ),
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  _getHealthStatusName(metrics.healthStatus),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last Updated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsExtension.getGrey600(context),
                      fontSize: UIConstants.fontSizeXs,
                    ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('HH:mm:ss').format(metrics.lastUpdated),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColorsExtension.getTextPrimary(context),
                          fontWeight: FontWeight.w600,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeMetrics(BuildContext context, SystemMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              'Active Users & Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorsExtension.getTextPrimary(context),
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingLg),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Active Users',
                value: _formatNumber(metrics.activeUsers),
                icon: Icons.people_rounded,
                color: AppColors.info,
                gradient: AppColors.infoGradient,
                subtitle: 'Currently online',
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Active Sessions',
                value: _formatNumber(metrics.activeSessions),
                icon: Icons.devices_rounded,
                color: AppColors.secondary,
                gradient: AppColors.secondaryGradient,
                subtitle: 'Active connections',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemPerformance(BuildContext context, SystemMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.speed_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              'System Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorsExtension.getTextPrimary(context),
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingLg),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'API Calls/min',
                value: _formatNumber(metrics.apiCallsPerMinute),
                icon: Icons.api_rounded,
                color: AppColors.aiPrimary,
                gradient: AppColors.aiGradient,
                subtitle: 'Requests per minute',
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Avg Response Time',
                value: '${metrics.avgResponseTime.toStringAsFixed(0)}ms',
                icon: Icons.timer_rounded,
                color: _getResponseTimeColor(metrics.avgResponseTime),
                subtitle: 'Average latency',
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Error Count',
                value: metrics.errorCount.toString(),
                icon: Icons.error_outline_rounded,
                color: metrics.errorCount > 0
                    ? AppColors.error
                    : AppColors.success,
                gradient: metrics.errorCount > 0
                    ? AppColors.errorGradient
                    : AppColors.successGradient,
                subtitle: 'Current errors',
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Error Rate',
                value: '${metrics.errorRate.toStringAsFixed(2)}%',
                icon: Icons.trending_down_rounded,
                color: _getErrorRateColor(metrics.errorRate),
                subtitle: 'Error percentage',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getHealthStatusColor(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return AppColors.success;
      case SystemHealthStatus.warning:
        return AppColors.warning;
      case SystemHealthStatus.critical:
        return AppColors.error;
    }
  }

  String _getHealthStatusName(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return 'Healthy';
      case SystemHealthStatus.warning:
        return 'Warning';
      case SystemHealthStatus.critical:
        return 'Critical';
    }
  }

  String _getHealthStatusEmoji(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return '🟢';
      case SystemHealthStatus.warning:
        return '🟡';
      case SystemHealthStatus.critical:
        return '🔴';
    }
  }

  Color _getResponseTimeColor(double responseTime) {
    if (responseTime < 200) {
      return AppColors.success;
    } else if (responseTime < 500) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  Color _getErrorRateColor(double errorRate) {
    if (errorRate < 1.0) {
      return AppColors.success;
    } else if (errorRate < 3.0) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

