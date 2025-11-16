import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<ReviewAnalyticsModel> getWeeklyReviewData(String vendorId);
  Future<ReviewAnalyticsModel> getMonthlyReviewData(String vendorId);
  Future<FavouriteStatsModel> getFavouriteData(String vendorId);
  Future<PromotionAnalyticsModel> getPromotionAnalytics(String vendorId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;

  AnalyticsRemoteDataSourceImpl({required this.firestore});

  /// Helper method to get all reviews for a restaurant and calculate overall stats
  Future<Map<String, dynamic>> _getAllReviewStats(String vendorId) async {
    final allReviewsSnapshot = await firestore
        .collection('reviews')
        .where('vendorId', isEqualTo: vendorId)
        .get();

    int totalReviews = 0;
    double totalRating = 0.0;
    final Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var doc in allReviewsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      // Try to get rating from 'rating' field, or calculate from aspectRatings
      double rating = 0.0;
      if (data['rating'] != null) {
        rating = (data['rating'] as num).toDouble();
      } else if (data['aspectRatings'] != null) {
        // Calculate average from aspectRatings if main rating doesn't exist
        final aspectRatings = data['aspectRatings'] as Map<String, dynamic>?;
        if (aspectRatings != null && aspectRatings.isNotEmpty) {
          final values = aspectRatings.values
              .where((v) => v is num)
              .map((v) => (v as num).toDouble())
              .toList();
          if (values.isNotEmpty) {
            rating = values.reduce((a, b) => a + b) / values.length;
          }
        }
      }

      if (rating > 0) {
        totalReviews++;
        totalRating += rating;
        
        // Round rating to nearest integer (1-5) for distribution
        final ratingInt = rating.round().clamp(1, 5);
        ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
      }
    }

    final overallAverage = totalReviews > 0 ? totalRating / totalReviews : 0.0;

    return {
      'overallAverage': overallAverage,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
    };
  }

  @override
  Future<ReviewAnalyticsModel> getWeeklyReviewData(String vendorId) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Get overall stats from all reviews
      final allStats = await _getAllReviewStats(vendorId);

      // Query reviews from the last 7 days for time-series data
      QuerySnapshot reviewsSnapshot;
      try {
        reviewsSnapshot = await firestore
            .collection('reviews')
            .where('vendorId', isEqualTo: vendorId)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
            .orderBy('createdAt', descending: false)
            .get();
      } catch (e) {
        reviewsSnapshot = await firestore
            .collection('reviews')
            .where('vendorId', isEqualTo: vendorId)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
            .orderBy('createdAt', descending: false)
            .get();
      }

      // Group reviews by day
      final Map<String, List<double>> dailyRatings = {};

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // Try to get rating from 'rating' field, or calculate from aspectRatings
        double rating = 0.0;
        if (data['rating'] != null) {
          rating = (data['rating'] as num).toDouble();
        } else if (data['aspectRatings'] != null) {
          // Calculate average from aspectRatings if main rating doesn't exist
          final aspectRatings = data['aspectRatings'] as Map<String, dynamic>?;
          if (aspectRatings != null && aspectRatings.isNotEmpty) {
            final values = aspectRatings.values
                .where((v) => v is num)
                .map((v) => (v as num).toDouble())
                .toList();
            if (values.isNotEmpty) {
              rating = values.reduce((a, b) => a + b) / values.length;
            }
          }
        }

        if (rating > 0) {
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
          final dayKey = _getDayKey(createdAt);
          dailyRatings.putIfAbsent(dayKey, () => []).add(rating);
        }
      }

      // Create data points for each day in the last 7 days
      final dataPoints = <ReviewDataPointModel>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayKey = _getDayKey(date);
        final ratings = dailyRatings[dayKey] ?? [];

        final average = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        dataPoints.add(
          ReviewDataPointModel(
            date: date,
            averageRating: average,
            reviewCount: ratings.length,
          ),
        );
      }

      return ReviewAnalyticsModel(
        dataPoints: dataPoints,
        overallAverage: allStats['overallAverage'] as double,
        totalReviews: allStats['totalReviews'] as int,
        ratingDistribution: allStats['ratingDistribution'] as Map<int, int>,
      );
    } catch (e) {
      throw Exception('Failed to get weekly review data: $e');
    }
  }

  @override
  Future<ReviewAnalyticsModel> getMonthlyReviewData(String vendorId) async {
    try {
      final now = DateTime.now();
      final fiveWeeksAgo = now.subtract(const Duration(days: 35));

      // Get overall stats from all reviews
      final allStats = await _getAllReviewStats(vendorId);

      // Query reviews from the last 5 weeks for time-series data
      QuerySnapshot reviewsSnapshot;
      try {
        reviewsSnapshot = await firestore
            .collection('reviews')
            .where('vendorId', isEqualTo: vendorId)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(fiveWeeksAgo))
            .orderBy('createdAt', descending: false)
            .get();
      } catch (e) {
        reviewsSnapshot = await firestore
            .collection('reviews')
            .where('vendorId', isEqualTo: vendorId)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(fiveWeeksAgo))
            .orderBy('createdAt', descending: false)
            .get();
      }

      // Group reviews by week
      final Map<String, List<double>> weeklyRatings = {};

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // Try to get rating from 'rating' field, or calculate from aspectRatings
        double rating = 0.0;
        if (data['rating'] != null) {
          rating = (data['rating'] as num).toDouble();
        } else if (data['aspectRatings'] != null) {
          // Calculate average from aspectRatings if main rating doesn't exist
          final aspectRatings = data['aspectRatings'] as Map<String, dynamic>?;
          if (aspectRatings != null && aspectRatings.isNotEmpty) {
            final values = aspectRatings.values
                .where((v) => v is num)
                .map((v) => (v as num).toDouble())
                .toList();
            if (values.isNotEmpty) {
              rating = values.reduce((a, b) => a + b) / values.length;
            }
          }
        }

        if (rating > 0) {
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
          final weekKey = _getWeekKey(createdAt);
          weeklyRatings.putIfAbsent(weekKey, () => []).add(rating);
        }
      }

      // Create data points for each week in the last 5 weeks
      final dataPoints = <ReviewDataPointModel>[];
      for (int i = 4; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: i * 7));
        final weekKey = _getWeekKey(weekStart);
        final ratings = weeklyRatings[weekKey] ?? [];

        final average = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        dataPoints.add(
          ReviewDataPointModel(
            date: weekStart,
            averageRating: average,
            reviewCount: ratings.length,
          ),
        );
      }

      return ReviewAnalyticsModel(
        dataPoints: dataPoints,
        overallAverage: allStats['overallAverage'] as double,
        totalReviews: allStats['totalReviews'] as int,
        ratingDistribution: allStats['ratingDistribution'] as Map<int, int>,
      );
    } catch (e) {
      throw Exception('Failed to get monthly review data: $e');
    }
  }

  @override
  Future<FavouriteStatsModel> getFavouriteData(String vendorId) async {
    try {
      // Favorites are stored as: favorites/{userId}/items/{vendorId}
      // The item document has an 'id' field with the vendorId
      // We use collection group query to search across all users' favorites
      final itemsSnapshot = await firestore
          .collectionGroup('items')
          .where('id', isEqualTo: vendorId)
          .get();

      final totalFavourites = itemsSnapshot.docs.length;

      // For monthly trending, we could calculate previous month's count
      // For now, we'll return the current count
      return FavouriteStatsModel(
        totalFavourites: totalFavourites,
        previousMonthFavourites:
            null, // TODO: Implement monthly trending if needed
        percentageChange: null,
      );
    } catch (e) {
      throw Exception('Failed to get favourite data: $e');
    }
  }

  @override
  Future<PromotionAnalyticsModel> getPromotionAnalytics(String vendorId) async {
    try {
      final promotionsSnapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .get();

      final promotionEngagements = <PromotionEngagementModel>[];
      int totalClicks = 0;
      int totalRedeemed = 0;

      for (var promoDoc in promotionsSnapshot.docs) {
        final data = promoDoc.data();

        final engagement = PromotionEngagementModel(
          promotionId: promoDoc.id,
          promotionTitle: data['title'] ?? 'Untitled Promotion',
          views: data['clickCount'] ?? 0,
          clicks: data['clickCount'] ?? 0,
          redeemed: data['redeemedCount'] ?? 0,
        );

        promotionEngagements.add(engagement);

        totalClicks += engagement.clicks;
        totalRedeemed += engagement.redeemed;
      }

      return PromotionAnalyticsModel(
        promotions: promotionEngagements,
        totalViews: totalClicks,
        totalClicks: totalClicks,
        totalRedeemed: totalRedeemed,
      );
    } catch (e) {
      throw Exception('Failed to get promotion analytics: $e');
    }
  }



  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekKey(DateTime date) {
    // Get the start of the week (Monday)
    final weekday = date.weekday;
    final weekStart = date.subtract(Duration(days: weekday - 1));
    return '${weekStart.year}-W${_getWeekNumber(weekStart)}';
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }
}
