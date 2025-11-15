import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/analytics_entity.dart';

class ReviewDataPointModel {
  final DateTime date;
  final double averageRating;
  final int reviewCount;

  ReviewDataPointModel({
    required this.date,
    required this.averageRating,
    required this.reviewCount,
  });

  ReviewDataPoint toEntity() {
    return ReviewDataPoint(
      date: date,
      averageRating: averageRating,
      reviewCount: reviewCount,
    );
  }
}

class ReviewAnalyticsModel {
  final List<ReviewDataPointModel> dataPoints;
  final double overallAverage;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewAnalyticsModel({
    required this.dataPoints,
    required this.overallAverage,
    required this.totalReviews,
    this.ratingDistribution = const {},
  });

  ReviewAnalyticsEntity toEntity() {
    return ReviewAnalyticsEntity(
      dataPoints: dataPoints.map((dp) => dp.toEntity()).toList(),
      overallAverage: overallAverage,
      totalReviews: totalReviews,
      ratingDistribution: ratingDistribution,
    );
  }
}

class FavouriteStatsModel {
  final int totalFavourites;
  final int? previousMonthFavourites;
  final double? percentageChange;

  FavouriteStatsModel({
    required this.totalFavourites,
    this.previousMonthFavourites,
    this.percentageChange,
  });

  FavouriteStatsEntity toEntity() {
    return FavouriteStatsEntity(
      totalFavourites: totalFavourites,
      previousMonthFavourites: previousMonthFavourites,
      percentageChange: percentageChange,
    );
  }

  factory FavouriteStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final total = data['totalFavourites'] as int? ?? 0;
    final previous = data['previousMonthFavourites'] as int?;
    
    double? percentageChange;
    if (previous != null && previous > 0) {
      percentageChange = ((total - previous) / previous) * 100;
    }

    return FavouriteStatsModel(
      totalFavourites: total,
      previousMonthFavourites: previous,
      percentageChange: percentageChange,
    );
  }
}

class PromotionEngagementModel {
  final String promotionId;
  final String promotionTitle;
  final int views;
  final int clicks;
  final int redeemed;

  PromotionEngagementModel({
    required this.promotionId,
    required this.promotionTitle,
    required this.views,
    required this.clicks,
    required this.redeemed,
  });

  PromotionEngagementEntity toEntity() {
    return PromotionEngagementEntity(
      promotionId: promotionId,
      promotionTitle: promotionTitle,
      views: views,
      clicks: clicks,
      redeemed: redeemed,
    );
  }

  factory PromotionEngagementModel.fromFirestore(
    DocumentSnapshot doc,
    String promotionTitle,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PromotionEngagementModel(
      promotionId: doc.id,
      promotionTitle: promotionTitle,
      views: data['views'] as int? ?? 0,
      clicks: data['clicks'] as int? ?? 0,
      redeemed: data['redeemed'] as int? ?? 0,
    );
  }
}

class PromotionAnalyticsModel {
  final List<PromotionEngagementModel> promotions;
  final int totalViews;
  final int totalClicks;
  final int totalRedeemed;

  PromotionAnalyticsModel({
    required this.promotions,
    required this.totalViews,
    required this.totalClicks,
    required this.totalRedeemed,
  });

  PromotionAnalyticsEntity toEntity() {
    return PromotionAnalyticsEntity(
      promotions: promotions.map((p) => p.toEntity()).toList(),
      totalViews: totalViews,
      totalClicks: totalClicks,
      totalRedeemed: totalRedeemed,
    );
  }
}

