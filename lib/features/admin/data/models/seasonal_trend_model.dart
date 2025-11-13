import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/base_model.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';

/// Model for seasonal trend analysis
class SeasonalTrendAnalysisModel extends BaseModel {
  final Season currentSeason;
  final List<TrendingDish> trendingDishes;
  final List<TrendingCuisine> trendingCuisines;
  final List<UpcomingEvent> upcomingEvents;
  final List<AdminRecommendation> recommendations;
  final DateTime analysisStartDate;
  final DateTime analysisEndDate;
  final DateTime calculatedAt;
  final int totalSearches;

  const SeasonalTrendAnalysisModel({
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

  /// Convert to entity
  SeasonalTrendAnalysis toEntity() {
    return SeasonalTrendAnalysis(
      currentSeason: currentSeason,
      trendingDishes: trendingDishes,
      trendingCuisines: trendingCuisines,
      upcomingEvents: upcomingEvents,
      recommendations: recommendations,
      analysisStartDate: analysisStartDate,
      analysisEndDate: analysisEndDate,
      calculatedAt: calculatedAt,
      totalSearches: totalSearches,
    );
  }

  /// Create from entity
  factory SeasonalTrendAnalysisModel.fromEntity(
    SeasonalTrendAnalysis entity,
  ) {
    return SeasonalTrendAnalysisModel(
      currentSeason: entity.currentSeason,
      trendingDishes: entity.trendingDishes,
      trendingCuisines: entity.trendingCuisines,
      upcomingEvents: entity.upcomingEvents,
      recommendations: entity.recommendations,
      analysisStartDate: entity.analysisStartDate,
      analysisEndDate: entity.analysisEndDate,
      calculatedAt: entity.calculatedAt,
      totalSearches: entity.totalSearches,
    );
  }

  /// Create from Firestore document
  factory SeasonalTrendAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SeasonalTrendAnalysisModel(
      currentSeason: _seasonFromString(data['currentSeason'] as String? ?? 'regular'),
      trendingDishes: _parseTrendingDishes(data['trendingDishes'] as List? ?? []),
      trendingCuisines: _parseTrendingCuisines(data['trendingCuisines'] as List? ?? []),
      upcomingEvents: _parseUpcomingEvents(data['upcomingEvents'] as List? ?? []),
      recommendations: _parseRecommendations(data['recommendations'] as List? ?? []),
      analysisStartDate: (data['analysisStartDate'] as Timestamp).toDate(),
      analysisEndDate: (data['analysisEndDate'] as Timestamp).toDate(),
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      totalSearches: data['totalSearches'] as int? ?? 0,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'currentSeason': _seasonToString(currentSeason),
      'trendingDishes': trendingDishes.map((d) => {
            'dishName': d.dishName,
            'percentageChange': d.percentageChange,
            'currentCount': d.currentCount,
            'previousCount': d.previousCount,
            'cuisineType': d.cuisineType,
          }).toList(),
      'trendingCuisines': trendingCuisines.map((c) => {
            'cuisineName': c.cuisineName,
            'percentageChange': c.percentageChange,
            'currentCount': c.currentCount,
            'previousCount': c.previousCount,
          }).toList(),
      'upcomingEvents': upcomingEvents.map((e) => {
            'eventName': e.eventName,
            'daysUntil': e.daysUntil,
            'impact': _impactToString(e.impact),
            'predictedTrendingItems': e.predictedTrendingItems,
          }).toList(),
      'recommendations': recommendations.map((r) => {
            'title': r.title,
            'description': r.description,
            'type': _typeToString(r.type),
            'priority': _priorityToString(r.priority),
          }).toList(),
      'analysisStartDate': Timestamp.fromDate(analysisStartDate),
      'analysisEndDate': Timestamp.fromDate(analysisEndDate),
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'totalSearches': totalSearches,
    };
  }

  static Season _seasonFromString(String season) {
    switch (season.toLowerCase()) {
      case 'ramadan':
        return Season.ramadan;
      case 'cny':
        return Season.cny;
      case 'durian':
        return Season.durian;
      default:
        return Season.regular;
    }
  }

  static String _seasonToString(Season season) {
    switch (season) {
      case Season.ramadan:
        return 'ramadan';
      case Season.cny:
        return 'cny';
      case Season.durian:
        return 'durian';
      case Season.regular:
        return 'regular';
    }
  }

  static List<TrendingDish> _parseTrendingDishes(List<dynamic> data) {
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return TrendingDish(
        dishName: map['dishName'] as String,
        percentageChange: (map['percentageChange'] as num).toDouble(),
        currentCount: map['currentCount'] as int,
        previousCount: map['previousCount'] as int,
        cuisineType: map['cuisineType'] as String,
      );
    }).toList();
  }

  static List<TrendingCuisine> _parseTrendingCuisines(List<dynamic> data) {
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return TrendingCuisine(
        cuisineName: map['cuisineName'] as String,
        percentageChange: (map['percentageChange'] as num).toDouble(),
        currentCount: map['currentCount'] as int,
        previousCount: map['previousCount'] as int,
      );
    }).toList();
  }

  static List<UpcomingEvent> _parseUpcomingEvents(List<dynamic> data) {
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return UpcomingEvent(
        eventName: map['eventName'] as String,
        daysUntil: map['daysUntil'] as int,
        impact: _impactFromString(map['impact'] as String? ?? 'low'),
        predictedTrendingItems: List<String>.from(map['predictedTrendingItems'] as List? ?? []),
      );
    }).toList();
  }

  static List<AdminRecommendation> _parseRecommendations(List<dynamic> data) {
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminRecommendation(
        title: map['title'] as String,
        description: map['description'] as String,
        type: _typeFromString(map['type'] as String? ?? 'marketingCampaign'),
        priority: _priorityFromString(map['priority'] as String? ?? 'medium'),
      );
    }).toList();
  }

  static EventImpact _impactFromString(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return EventImpact.high;
      case 'medium':
        return EventImpact.medium;
      default:
        return EventImpact.low;
    }
  }

  static String _impactToString(EventImpact impact) {
    switch (impact) {
      case EventImpact.high:
        return 'high';
      case EventImpact.medium:
        return 'medium';
      case EventImpact.low:
        return 'low';
    }
  }

  static RecommendationType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'vendorpromotion':
        return RecommendationType.vendorPromotion;
      case 'contentboost':
        return RecommendationType.contentBoost;
      case 'inventorymanagement':
        return RecommendationType.inventoryManagement;
      case 'marketingcampaign':
        return RecommendationType.marketingCampaign;
      case 'featurehighlight':
        return RecommendationType.featureHighlight;
      default:
        return RecommendationType.marketingCampaign;
    }
  }

  static String _typeToString(RecommendationType type) {
    switch (type) {
      case RecommendationType.vendorPromotion:
        return 'vendorPromotion';
      case RecommendationType.contentBoost:
        return 'contentBoost';
      case RecommendationType.inventoryManagement:
        return 'inventoryManagement';
      case RecommendationType.marketingCampaign:
        return 'marketingCampaign';
      case RecommendationType.featureHighlight:
        return 'featureHighlight';
    }
  }

  static RecommendationPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return RecommendationPriority.high;
      case 'medium':
        return RecommendationPriority.medium;
      default:
        return RecommendationPriority.low;
    }
  }

  static String _priorityToString(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return 'high';
      case RecommendationPriority.medium:
        return 'medium';
      case RecommendationPriority.low:
        return 'low';
    }
  }

  @override
  Map<String, dynamic> toJson() => toFirestore();

  @override
  List<Object?> get props => [
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
}

