import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:makan_mate/core/widgets/loading_widget.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';
import 'package:intl/intl.dart';

/// Seasonal Insights Widget
///
/// Displays seasonal trend analysis including:
/// - Current season detection
/// - Trending dishes with percentage changes
/// - Trending cuisines
/// - Upcoming events predictions
/// - Admin recommendations
class SeasonalInsightsWidget extends StatelessWidget {
  const SeasonalInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoaded && state.seasonalTrends != null) {
          return _buildDashboard(context, state.seasonalTrends!);
        } else if (state is AdminLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(UIConstants.spacingXl),
              child: LoadingWidget(),
            ),
          );
        } else {
          // Load seasonal trends from real data (no mock data)
          context.read<AdminBloc>().add(const LoadSeasonalTrends());
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(UIConstants.spacingXl),
              child: LoadingWidget(),
            ),
          );
        }
      },
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    SeasonalTrendAnalysis trends,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Season Card
        _buildCurrentSeasonCard(context, trends.currentSeason),
        const SizedBox(height: UIConstants.spacingLg),

        // Trending Dishes
        if (trends.trendingDishes.isNotEmpty) ...[
          _buildTrendingDishes(context, trends.trendingDishes),
          const SizedBox(height: UIConstants.spacingLg),
        ],

        // Trending Cuisines
        if (trends.trendingCuisines.isNotEmpty) ...[
          _buildTrendingCuisines(context, trends.trendingCuisines),
          const SizedBox(height: UIConstants.spacingLg),
        ],

        // Upcoming Events
        if (trends.upcomingEvents.isNotEmpty) ...[
          _buildUpcomingEvents(context, trends.upcomingEvents),
          const SizedBox(height: UIConstants.spacingLg),
        ],

        // Admin Recommendations
        if (trends.recommendations.isNotEmpty) ...[
          _buildRecommendations(context, trends.recommendations),
          const SizedBox(height: UIConstants.spacingLg),
        ],

        // Analysis Info
        _buildAnalysisInfo(context, trends),
      ],
    );
  }

  Widget _buildCurrentSeasonCard(BuildContext context, Season season) {
    final seasonColor = _getSeasonColor(season);

    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  seasonColor.withOpacity(0.3),
                  seasonColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              season.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(width: UIConstants.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Season',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorsExtension.getTextSecondary(context),
                        fontSize: UIConstants.fontSizeSm,
                      ),
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  '${season.displayName} ${season.emoji}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: seasonColor,
                      ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<AdminBloc>().add(const RefreshSeasonalTrends());
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDishes(
    BuildContext context,
    List<TrendingDish> dishes,
  ) {
    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Trending Dishes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          ...dishes.take(10).map((dish) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: _buildTrendingItem(
                  context,
                  dish.dishName,
                  dish.percentageChange,
                  dish.currentCount,
                  dish.previousCount,
                  dish.cuisineType,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTrendingCuisines(
    BuildContext context,
    List<TrendingCuisine> cuisines,
  ) {
    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_dining_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Trending Cuisines',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          ...cuisines.map((cuisine) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: _buildTrendingItem(
                  context,
                  cuisine.cuisineName,
                  cuisine.percentageChange,
                  cuisine.currentCount,
                  cuisine.previousCount,
                  null,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(
    BuildContext context,
    String name,
    double percentageChange,
    int currentCount,
    int previousCount,
    String? cuisineType,
  ) {
    final isUp = percentageChange > 0;
    final color = isUp ? AppColors.success : AppColors.error;
    final icon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.grey50,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsExtension.getTextPrimary(context),
                      ),
                ),
                if (cuisineType != null) ...[
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    cuisineType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsExtension.getTextSecondary(context),
                          fontSize: UIConstants.fontSizeXs,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isUp ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: UIConstants.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentCount vs $previousCount',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsExtension.getTextSecondary(context),
                      fontSize: UIConstants.fontSizeXs,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(
    BuildContext context,
    List<UpcomingEvent> events,
  ) {
    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.warningGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          ...events.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: _buildEventItem(context, event),
              )),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, UpcomingEvent event) {
    final impactColor = _getImpactColor(event.impact);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.1),
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: impactColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                color: impactColor,
                size: 24,
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Expanded(
                child: Text(
                  event.eventName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: impactColor,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingSm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [impactColor, impactColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: impactColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  '${event.daysUntil} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: UIConstants.fontSizeXs,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColorsExtension.getGrey600(context),
              ),
              const SizedBox(width: 4),
              Text(
                event.impact.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsExtension.getTextSecondary(context),
                      fontSize: UIConstants.fontSizeXs,
                    ),
              ),
            ],
          ),
          if (event.predictedTrendingItems.isNotEmpty) ...[
            const SizedBox(height: UIConstants.spacingMd),
            Text(
              'Predicted Trending:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsExtension.getTextPrimary(context),
                    fontSize: UIConstants.fontSizeSm,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingXs),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: event.predictedTrendingItems
                  .take(5)
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.grey300,
                        ),
                      ),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: UIConstants.fontSizeXs,
                              color: AppColorsExtension.getTextPrimary(context),
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    List<AdminRecommendation> recommendations,
  ) {
    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Admin Recommendations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                child: _buildRecommendationItem(context, rec),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    AdminRecommendation recommendation,
  ) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    final typeIcon = _getTypeIcon(recommendation.type);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: priorityColor, size: 18),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recommendation.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeXs,
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingSm),
          Text(
            recommendation.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInfo(
    BuildContext context,
    SeasonalTrendAnalysis trends,
  ) {
    return GlassContainer(
      padding: UIConstants.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.infoGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Text(
                'Analysis Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          _buildInfoRow(
            context,
            'Analysis Period',
            '${_formatDate(trends.analysisStartDate)} - ${_formatDate(trends.analysisEndDate)}',
          ),
          _buildInfoRow(
            context,
            'Total Searches Analyzed',
            '${trends.totalSearches}',
          ),
          _buildInfoRow(
            context,
            'Calculated At',
            _formatDateTime(trends.calculatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsExtension.getTextPrimary(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeasonColor(Season season) {
    switch (season) {
      case Season.ramadan:
        return AppColors.secondary;
      case Season.cny:
        return AppColors.error;
      case Season.durian:
        return AppColors.warning;
      case Season.regular:
        return AppColors.info;
    }
  }

  Color _getImpactColor(EventImpact impact) {
    switch (impact) {
      case EventImpact.high:
        return AppColors.error;
      case EventImpact.medium:
        return AppColors.warning;
      case EventImpact.low:
        return AppColors.info;
    }
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return AppColors.error;
      case RecommendationPriority.medium:
        return AppColors.warning;
      case RecommendationPriority.low:
        return AppColors.info;
    }
  }

  IconData _getTypeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.vendorPromotion:
        return Icons.store;
      case RecommendationType.contentBoost:
        return Icons.trending_up;
      case RecommendationType.inventoryManagement:
        return Icons.inventory;
      case RecommendationType.marketingCampaign:
        return Icons.campaign;
      case RecommendationType.featureHighlight:
        return Icons.star;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
}


