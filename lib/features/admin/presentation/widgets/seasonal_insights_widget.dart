import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';

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
          return const Center(child: CircularProgressIndicator());
        } else {
          // Load seasonal trends if not loaded
          context.read<AdminBloc>().add(const LoadSeasonalTrends());
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    SeasonalTrendAnalysis trends,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const RefreshSeasonalTrends());
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
                  'Seasonal Trend Analysis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AdminBloc>().add(const RefreshSeasonalTrends());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDateTime(trends.calculatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Current Season Card
            _buildCurrentSeasonCard(context, trends.currentSeason),
            const SizedBox(height: 24),

            // Trending Dishes
            if (trends.trendingDishes.isNotEmpty) ...[
              _buildTrendingDishes(context, trends.trendingDishes),
              const SizedBox(height: 24),
            ],

            // Trending Cuisines
            if (trends.trendingCuisines.isNotEmpty) ...[
              _buildTrendingCuisines(context, trends.trendingCuisines),
              const SizedBox(height: 24),
            ],

            // Upcoming Events
            if (trends.upcomingEvents.isNotEmpty) ...[
              _buildUpcomingEvents(context, trends.upcomingEvents),
              const SizedBox(height: 24),
            ],

            // Admin Recommendations
            if (trends.recommendations.isNotEmpty) ...[
              _buildRecommendations(context, trends.recommendations),
              const SizedBox(height: 24),
            ],

            // Analysis Info
            _buildAnalysisInfo(context, trends),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSeasonCard(BuildContext context, Season season) {
    return Card(
      elevation: 3,
      color: _getSeasonColor(season).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(
              season.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Season',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${season.displayName} ${season.emoji}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getSeasonColor(season),
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

  Widget _buildTrendingDishes(
    BuildContext context,
    List<TrendingDish> dishes,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Dishes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dishes.take(10).map((dish) => _buildTrendingItem(
                  context,
                  dish.dishName,
                  dish.percentageChange,
                  dish.currentCount,
                  dish.previousCount,
                  dish.cuisineType,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCuisines(
    BuildContext context,
    List<TrendingCuisine> cuisines,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Cuisines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...cuisines.map((cuisine) => _buildTrendingItem(
                  context,
                  cuisine.cuisineName,
                  cuisine.percentageChange,
                  cuisine.currentCount,
                  cuisine.previousCount,
                  null,
                )),
          ],
        ),
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
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cuisineType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    cuisineType,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$currentCount vs $previousCount',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...events.map((event) => _buildEventItem(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, UpcomingEvent event) {
    final impactColor = _getImpactColor(event.impact);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: impactColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: impactColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.eventName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: impactColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: impactColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.daysUntil} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                event.impact.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (event.predictedTrendingItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Predicted Trending:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: event.predictedTrendingItems
                  .take(5)
                  .map(
                    (item) => Chip(
                      label: Text(
                        item,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Admin Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(context, rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    BuildContext context,
    AdminRecommendation recommendation,
  ) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    final typeIcon = _getTypeIcon(recommendation.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              Icon(typeIcon, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: TextStyle(
                    fontSize: 16,
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  recommendation.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
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
              '${_formatDate(trends.analysisStartDate)} - ${_formatDate(trends.analysisEndDate)}',
            ),
            _buildInfoRow(
              'Total Searches Analyzed',
              '${trends.totalSearches}',
            ),
            _buildInfoRow(
              'Calculated At',
              _formatDateTime(trends.calculatedAt),
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

  Color _getSeasonColor(Season season) {
    switch (season) {
      case Season.ramadan:
        return Colors.purple;
      case Season.cny:
        return Colors.red;
      case Season.durian:
        return Colors.orange;
      case Season.regular:
        return Colors.blue;
    }
  }

  Color _getImpactColor(EventImpact impact) {
    switch (impact) {
      case EventImpact.high:
        return Colors.red;
      case EventImpact.medium:
        return Colors.orange;
      case EventImpact.low:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.low:
        return Colors.blue;
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
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}


