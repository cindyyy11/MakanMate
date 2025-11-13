import 'package:equatable/equatable.dart';

/// Seasonal trend analysis entity
///
/// Tracks seasonal patterns in food searches, orders, and preferences
/// to help admins understand and predict trends
class SeasonalTrendAnalysis extends Equatable {
  /// Current detected season
  final Season currentSeason;

  /// Trending dishes with percentage change
  final List<TrendingDish> trendingDishes;

  /// Trending cuisines with percentage change
  final List<TrendingCuisine> trendingCuisines;

  /// Upcoming events predictions
  final List<UpcomingEvent> upcomingEvents;

  /// Admin recommendations based on trends
  final List<AdminRecommendation> recommendations;

  /// Analysis period start
  final DateTime analysisStartDate;

  /// Analysis period end
  final DateTime analysisEndDate;

  /// When analysis was calculated
  final DateTime calculatedAt;

  /// Total searches analyzed
  final int totalSearches;

  const SeasonalTrendAnalysis({
    required this.currentSeason,
    required this.trendingDishes,
    required this.trendingCuisines,
    required this.upcomingEvents,
    required this.recommendations,
    required this.analysisStartDate,
    required this.analysisEndDate,
    required this.calculatedAt,
    required this.totalSearches,
  });

  @override
  List<Object> get props => [
    currentSeason,
    trendingDishes,
    trendingCuisines,
    upcomingEvents,
    recommendations,
    analysisStartDate,
    analysisEndDate,
    calculatedAt,
    totalSearches,
  ];

  SeasonalTrendAnalysis copyWith({
    Season? currentSeason,
    List<TrendingDish>? trendingDishes,
    List<TrendingCuisine>? trendingCuisines,
    List<UpcomingEvent>? upcomingEvents,
    List<AdminRecommendation>? recommendations,
    DateTime? analysisStartDate,
    DateTime? analysisEndDate,
    DateTime? calculatedAt,
    int? totalSearches,
  }) {
    return SeasonalTrendAnalysis(
      currentSeason: currentSeason ?? this.currentSeason,
      trendingDishes: trendingDishes ?? this.trendingDishes,
      trendingCuisines: trendingCuisines ?? this.trendingCuisines,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      recommendations: recommendations ?? this.recommendations,
      analysisStartDate: analysisStartDate ?? this.analysisStartDate,
      analysisEndDate: analysisEndDate ?? this.analysisEndDate,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      totalSearches: totalSearches ?? this.totalSearches,
    );
  }
}

/// Season enum
enum Season { ramadan, cny, durian, regular }

/// Extension for season display
extension SeasonExtension on Season {
  String get displayName {
    switch (this) {
      case Season.ramadan:
        return 'Ramadan';
      case Season.cny:
        return 'Chinese New Year';
      case Season.durian:
        return 'Durian Season';
      case Season.regular:
        return 'Regular Season';
    }
  }

  String get emoji {
    switch (this) {
      case Season.ramadan:
        return '🌙';
      case Season.cny:
        return '🧧';
      case Season.durian:
        return '🌳';
      case Season.regular:
        return '🍽️';
    }
  }
}

/// Trending dish information
class TrendingDish extends Equatable {
  /// Dish name
  final String dishName;

  /// Percentage change (positive = trending up, negative = trending down)
  final double percentageChange;

  /// Current search count
  final int currentCount;

  /// Previous period search count
  final int previousCount;

  /// Cuisine type
  final String cuisineType;

  const TrendingDish({
    required this.dishName,
    required this.percentageChange,
    required this.currentCount,
    required this.previousCount,
    required this.cuisineType,
  });

  @override
  List<Object> get props => [
    dishName,
    percentageChange,
    currentCount,
    previousCount,
    cuisineType,
  ];

  bool get isTrendingUp => percentageChange > 0;
}

/// Trending cuisine information
class TrendingCuisine extends Equatable {
  /// Cuisine name
  final String cuisineName;

  /// Percentage change
  final double percentageChange;

  /// Current search count
  final int currentCount;

  /// Previous period search count
  final int previousCount;

  const TrendingCuisine({
    required this.cuisineName,
    required this.percentageChange,
    required this.currentCount,
    required this.previousCount,
  });

  @override
  List<Object> get props => [
    cuisineName,
    percentageChange,
    currentCount,
    previousCount,
  ];

  bool get isTrendingUp => percentageChange > 0;
}

/// Upcoming event prediction
class UpcomingEvent extends Equatable {
  /// Event name
  final String eventName;

  /// Days until event
  final int daysUntil;

  /// Expected impact (high, medium, low)
  final EventImpact impact;

  /// Predicted trending items
  final List<String> predictedTrendingItems;

  const UpcomingEvent({
    required this.eventName,
    required this.daysUntil,
    required this.impact,
    required this.predictedTrendingItems,
  });

  @override
  List<Object> get props => [
    eventName,
    daysUntil,
    impact,
    predictedTrendingItems,
  ];
}

/// Event impact level
enum EventImpact { high, medium, low }

/// Extension for event impact display
extension EventImpactExtension on EventImpact {
  String get displayName {
    switch (this) {
      case EventImpact.high:
        return 'High Impact';
      case EventImpact.medium:
        return 'Medium Impact';
      case EventImpact.low:
        return 'Low Impact';
    }
  }
}

/// Admin recommendation based on trend analysis
class AdminRecommendation extends Equatable {
  /// Recommendation title
  final String title;

  /// Detailed recommendation description
  final String description;

  /// Recommendation type
  final RecommendationType type;

  /// Priority level
  final RecommendationPriority priority;

  const AdminRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });

  @override
  List<Object> get props => [title, description, type, priority];
}

/// Recommendation type
enum RecommendationType {
  vendorPromotion,
  contentBoost,
  inventoryManagement,
  marketingCampaign,
  featureHighlight,
}

/// Recommendation priority
enum RecommendationPriority { high, medium, low }
