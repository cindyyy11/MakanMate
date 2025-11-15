import 'package:equatable/equatable.dart';

/// Review data point for analytics
class ReviewDataPoint extends Equatable {
  final DateTime date;
  final double averageRating;
  final int reviewCount;

  const ReviewDataPoint({
    required this.date,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  List<Object?> get props => [date, averageRating, reviewCount];
}

/// Review analytics entity
class ReviewAnalyticsEntity extends Equatable {
  final List<ReviewDataPoint> dataPoints;
  final double overallAverage;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // Map of rating (1-5) to count

  const ReviewAnalyticsEntity({
    required this.dataPoints,
    required this.overallAverage,
    required this.totalReviews,
    this.ratingDistribution = const {},
  });

  @override
  List<Object?> get props => [dataPoints, overallAverage, totalReviews, ratingDistribution];
}

/// Favourite statistics entity
class FavouriteStatsEntity extends Equatable {
  final int totalFavourites;
  final int? previousMonthFavourites;
  final double? percentageChange;

  const FavouriteStatsEntity({
    required this.totalFavourites,
    this.previousMonthFavourites,
    this.percentageChange,
  });

  @override
  List<Object?> get props => [totalFavourites, previousMonthFavourites, percentageChange];
}

/// Promotion engagement data point
class PromotionEngagementEntity extends Equatable {
  final String promotionId;
  final String promotionTitle;
  final int views;
  final int clicks;
  final int redeemed;

  const PromotionEngagementEntity({
    required this.promotionId,
    required this.promotionTitle,
    required this.views,
    required this.clicks,
    required this.redeemed,
  });

  double get conversionRate {
    if (clicks == 0) return 0.0;
    return (redeemed / clicks) * 100;
  }

  @override
  List<Object?> get props => [promotionId, promotionTitle, views, clicks, redeemed];
}

/// Overall promotion analytics entity
class PromotionAnalyticsEntity extends Equatable {
  final List<PromotionEngagementEntity> promotions;
  final int totalViews;
  final int totalClicks;
  final int totalRedeemed;

  const PromotionAnalyticsEntity({
    required this.promotions,
    required this.totalViews,
    required this.totalClicks,
    required this.totalRedeemed,
  });

  double get overallConversionRate {
    if (totalClicks == 0) return 0.0;
    return (totalRedeemed / totalClicks) * 100;
  }

  @override
  List<Object?> get props => [promotions, totalViews, totalClicks, totalRedeemed];
}

