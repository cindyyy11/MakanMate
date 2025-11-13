import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/recommendations/data/models/recommendation_models.dart';

/// Local data source for caching recommendations
/// 
/// Uses Hive for fast local storage
abstract class RecommendationLocalDataSource {
  Future<List<RecommendationItem>> getCachedRecommendations(String userId);
  Future<void> cacheRecommendations(String userId, List<RecommendationItem> recommendations);
  Future<void> clearCache(String userId);
  Future<bool> isCacheValid(String userId);
}

/// Implementation of local data source
class RecommendationLocalDataSourceImpl implements RecommendationLocalDataSource {
  final Box<dynamic> recommendationBox;
  final Logger logger;
  
  // Cache expiry time (1 hour)
  static const int cacheExpiryHours = 1;

  RecommendationLocalDataSourceImpl({
    required this.recommendationBox,
    required this.logger,
  });

  @override
  Future<List<RecommendationItem>> getCachedRecommendations(String userId) async {
    try {
      final cacheData = recommendationBox.get(userId);
      
      if (cacheData == null) {
        logger.i('No cached recommendations found for user: $userId');
        return [];
      }

      final cacheMap = cacheData as Map;
      final cachedAt = DateTime.parse(cacheMap['cachedAt'] as String);
      
      // Check if cache is expired
      if (DateTime.now().difference(cachedAt).inHours > cacheExpiryHours) {
        logger.i('Cache expired for user: $userId');
        await clearCache(userId);
        return [];
      }

      final recommendationsJson = List<Map<String, dynamic>>.from(
        cacheMap['recommendations'] as List,
      );

      final recommendations = recommendationsJson
          .map((json) => RecommendationItem.fromJson(json))
          .toList();

      logger.i('Retrieved ${recommendations.length} cached recommendations');
      return recommendations;
    } catch (e, stackTrace) {
      logger.e('Error getting cached recommendations: $e', stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> cacheRecommendations(
    String userId,
    List<RecommendationItem> recommendations,
  ) async {
    try {
      final cacheData = {
        'userId': userId,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await recommendationBox.put(userId, cacheData);
      logger.i('Cached ${recommendations.length} recommendations for user: $userId');
    } catch (e, stackTrace) {
      logger.e('Error caching recommendations: $e', stackTrace: stackTrace);
      // Don't throw - caching failures shouldn't break the app
    }
  }

  @override
  Future<void> clearCache(String userId) async {
    try {
      await recommendationBox.delete(userId);
      logger.i('Cleared cache for user: $userId');
    } catch (e) {
      logger.e('Error clearing cache: $e');
    }
  }

  @override
  Future<bool> isCacheValid(String userId) async {
    try {
      final cacheData = recommendationBox.get(userId);
      
      if (cacheData == null) return false;

      final cacheMap = cacheData as Map;
      final cachedAt = DateTime.parse(cacheMap['cachedAt'] as String);
      
      return DateTime.now().difference(cachedAt).inHours <= cacheExpiryHours;
    } catch (e) {
      logger.e('Error checking cache validity: $e');
      return false;
    }
  }
}

