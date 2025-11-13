import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/domain/entities/data_quality_metrics_entity.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';
import 'package:makan_mate/core/widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Data Quality Dashboard Widget
/// 
/// Displays comprehensive data quality metrics including:
/// - Overall Quality Score
/// - Menu Completeness
/// - Halal Verification Coverage
/// - Listing Staleness
/// - Location Accuracy
/// - Critical Issues List
class DataQualityDashboardWidget extends StatelessWidget {
  const DataQualityDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoaded && state.dataQualityMetrics != null) {
          return _buildDashboard(context, state.dataQualityMetrics!);
        } else if (state is AdminLoading) {
          return const Center(child: LoadingWidget());
        } else {
          // Load data quality metrics if not loaded
          context.read<AdminBloc>().add(const LoadDataQualityMetrics());
          return const Center(child: LoadingWidget());
        }
      },
    );
  }

  Widget _buildDashboard(BuildContext context, DataQualityMetrics metrics) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const RefreshDataQualityMetrics());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: UIConstants.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context, metrics),
            const SizedBox(height: UIConstants.spacingXl),

            // Overall Quality Score Card
            _buildOverallQualityCard(context, metrics),
            const SizedBox(height: UIConstants.spacingLg),

            // Key Metrics Grid
            _buildKeyMetricsGrid(context, metrics),
            const SizedBox(height: UIConstants.spacingXl),

            // Quality Breakdown Chart
            _buildQualityBreakdownChart(context, metrics),
            const SizedBox(height: UIConstants.spacingXl),

            // Critical Issues Section
            if (metrics.criticalIssues.isNotEmpty) ...[
              _buildCriticalIssuesSection(context, metrics),
              const SizedBox(height: UIConstants.spacingXl),
            ],

            // Vendor Breakdown
            _buildVendorBreakdown(context, metrics),
            const SizedBox(height: UIConstants.spacingXl),

            // Last Updated Info
            _buildLastUpdatedInfo(context, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DataQualityMetrics metrics) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: UIConstants.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C).withValues(alpha: 0.8),
                  const Color(0xFF1E1E1E).withValues(alpha: 0.8),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.grey200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Quality Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsExtension.getTextPrimary(
                                    context,
                                  ),
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Platform-wide data quality monitoring',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AdminBloc>().add(const RefreshDataQualityMetrics());
            },
            tooltip: 'Refresh metrics',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallQualityCard(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = metrics.overallQualityScore;
    final statusColor = _getQualityStatusColor(score);
    final statusIcon = _getQualityStatusIcon(score);
    final statusText = _getQualityStatusText(score);

    return Container(
      padding: UIConstants.paddingXl,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.2),
            statusColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Quality Score',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColorsExtension.getTextSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              height: 1,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          '%',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 12,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: UIConstants.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                statusIcon,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColorsExtension.getTextPrimary(context),
              ),
        ),
        const SizedBox(height: UIConstants.spacingLg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: UIConstants.spacingMd,
          mainAxisSpacing: UIConstants.spacingMd,
          childAspectRatio: 1.3,
          children: [
            _buildMetricCard(
              context,
              'Menu Completeness',
              '${metrics.menuCompleteness.toStringAsFixed(1)}%',
              '${metrics.vendorsWithCompleteMenus} of ${metrics.totalVendors} vendors',
              Icons.restaurant_menu_rounded,
              AppColors.success,
              metrics.menuCompleteness >= 70,
            ),
            _buildMetricCard(
              context,
              'Halal Verification',
              '${metrics.halalCoverage.toStringAsFixed(1)}%',
              '${metrics.vendorsWithValidHalalCerts} vendors certified',
              Icons.verified_rounded,
              AppColors.info,
              metrics.halalCoverage >= 70,
            ),
            _buildMetricCard(
              context,
              'Listing Staleness',
              '${metrics.staleness.toStringAsFixed(1)}%',
              '${metrics.vendorsStaleData} vendors need update',
              Icons.update_rounded,
              metrics.staleness <= 15 ? AppColors.success : AppColors.warning,
              metrics.staleness <= 15,
            ),
            _buildMetricCard(
              context,
              'Location Accuracy',
              '${metrics.locationAccuracy.toStringAsFixed(1)}%',
              'Valid coordinates',
              Icons.location_on_rounded,
              AppColors.secondary,
              metrics.locationAccuracy >= 90,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool isGood,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: isGood
              ? color.withValues(alpha: 0.3)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200),
          width: isGood ? 2 : 1,
        ),
        boxShadow: isGood
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isGood)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                )
              else
                Icon(
                  Icons.warning_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                  fontSize: UIConstants.fontSizeXs,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBreakdownChart(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    return Container(
      padding: UIConstants.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorsExtension.getTextPrimary(context),
                ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.primary,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Menu', 'Halal', 'Fresh', 'Location'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: Theme.of(context).textTheme.bodySmall,
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
                          '${value.toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.grey200,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: metrics.menuCompleteness,
                        color: AppColors.success,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: metrics.halalCoverage,
                        color: AppColors.info,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 100 - metrics.staleness,
                        color: metrics.staleness <= 15
                            ? AppColors.success
                            : AppColors.warning,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: metrics.locationAccuracy,
                        color: AppColors.secondary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalIssuesSection(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    final highPriorityIssues = metrics.criticalIssues
        .where((issue) => issue.severity == DataQualitySeverity.high)
        .toList();
    final mediumPriorityIssues = metrics.criticalIssues
        .where((issue) => issue.severity == DataQualitySeverity.medium)
        .toList();

    return Container(
      padding: UIConstants.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Critical Issues',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${metrics.criticalIssues.length}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          if (highPriorityIssues.isNotEmpty) ...[
            _buildIssueList(context, 'High Priority', highPriorityIssues),
            if (mediumPriorityIssues.isNotEmpty)
              const SizedBox(height: UIConstants.spacingMd),
          ],
          if (mediumPriorityIssues.isNotEmpty)
            _buildIssueList(context, 'Medium Priority', mediumPriorityIssues),
        ],
      ),
    );
  }

  Widget _buildIssueList(
    BuildContext context,
    String title,
    List<DataQualityIssue> issues,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsExtension.getTextSecondary(context),
              ),
        ),
        const SizedBox(height: UIConstants.spacingSm),
        ...issues.take(5).map((issue) => _buildIssueItem(context, issue)),
        if (issues.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: UIConstants.spacingSm),
            child: Text(
              'and ${issues.length - 5} more...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueItem(BuildContext context, DataQualityIssue issue) {
    final severityColor = _getSeverityColor(issue.severity);
    final issueIcon = _getIssueIcon(issue.issueType);

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(issueIcon, color: severityColor, size: 20),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.vendorName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsExtension.getTextPrimary(context),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  issue.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              issue.severity.toString().split('.').last.toUpperCase(),
              style: TextStyle(
                color: severityColor,
                fontSize: UIConstants.fontSizeXs,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorBreakdown(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    return Container(
      padding: UIConstants.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendor Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorsExtension.getTextPrimary(context),
                ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          _buildBreakdownItem(
            context,
            'Total Vendors',
            metrics.totalVendors.toString(),
            Icons.store_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildBreakdownItem(
            context,
            'Complete Menus',
            '${metrics.vendorsWithCompleteMenus} (${metrics.menuCompleteness.toStringAsFixed(1)}%)',
            Icons.restaurant_menu_rounded,
            AppColors.success,
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildBreakdownItem(
            context,
            'Valid Halal Certs',
            '${metrics.vendorsWithValidHalalCerts} (${metrics.halalCoverage.toStringAsFixed(1)}%)',
            Icons.verified_rounded,
            AppColors.info,
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildBreakdownItem(
            context,
            'Stale Data',
            '${metrics.vendorsStaleData} (${metrics.staleness.toStringAsFixed(1)}%)',
            Icons.update_rounded,
            AppColors.warning,
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildBreakdownItem(
            context,
            'Duplicate Listings',
            metrics.duplicateListings.toString(),
            Icons.copy_all_rounded,
            AppColors.error,
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildBreakdownItem(
            context,
            'Total Food Items',
            metrics.totalFoodItems.toString(),
            Icons.fastfood_rounded,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColorsExtension.getTextPrimary(context),
              ),
        ),
      ],
    );
  }

  Widget _buildLastUpdatedInfo(
    BuildContext context,
    DataQualityMetrics metrics,
  ) {
    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.grey50,
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: AppColorsExtension.getTextSecondary(context),
          ),
          const SizedBox(width: UIConstants.spacingSm),
          Text(
            'Last calculated: ${_formatDateTime(metrics.calculatedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Color _getQualityStatusColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getQualityStatusIcon(double score) {
    if (score >= 80) return Icons.check_circle_rounded;
    if (score >= 60) return Icons.warning_rounded;
    return Icons.error_rounded;
  }

  String _getQualityStatusText(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Needs Improvement';
    return 'Critical';
  }

  Color _getSeverityColor(DataQualitySeverity severity) {
    switch (severity) {
      case DataQualitySeverity.high:
        return AppColors.error;
      case DataQualitySeverity.medium:
        return AppColors.warning;
      case DataQualitySeverity.low:
        return AppColors.info;
    }
  }

  IconData _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'incomplete_menu':
        return Icons.restaurant_menu_rounded;
      case 'missing_halal_cert':
        return Icons.verified_rounded;
      case 'stale_data':
        return Icons.update_rounded;
      case 'duplicate_listing':
        return Icons.copy_all_rounded;
      case 'invalid_location':
        return Icons.location_off_rounded;
      default:
        return Icons.warning_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }
}

