import '../entities/analytics_entity.dart';

abstract class AnalyticsRepository {
  /// Get weekly review analytics (last 7 days)
  Future<ReviewAnalyticsEntity> getWeeklyReviewData(String vendorId);

  /// Get monthly review analytics (last 4-5 weeks)
  Future<ReviewAnalyticsEntity> getMonthlyReviewData(String vendorId);

  /// Get favourite statistics
  Future<FavouriteStatsEntity> getFavouriteData(String vendorId);

  /// Get promotion analytics
  Future<PromotionAnalyticsEntity> getPromotionAnalytics(String vendorId);
}

