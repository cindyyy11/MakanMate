import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';

/// Repository interface for recommendation operations
/// 
/// Following clean architecture principles, this defines the contract
/// that the data layer must implement
abstract class RecommendationRepository {
  /// Get personalized recommendations for a user
  /// 
  /// Returns [Right<List<RecommendationEntity>>] on success
  /// Returns [Left<Failure>] on error
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations({
    required String userId,
    int limit = 10,
    RecommendationContextEntity? context,
  });

  /// Get recommendations based on specific context
  Future<Either<Failure, List<RecommendationEntity>>> getContextualRecommendations({
    required String userId,
    required RecommendationContextEntity context,
    int limit = 10,
  });

  /// Get similar items based on a given item
  Future<Either<Failure, List<RecommendationEntity>>> getSimilarItems({
    required String itemId,
    int limit = 10,
  });

  /// Refresh recommendations (fetch new ones)
  Future<Either<Failure, List<RecommendationEntity>>> refreshRecommendations({
    required String userId,
    int limit = 10,
  });

  /// Track user interaction with recommendation
  Future<Either<Failure, void>> trackInteraction({
    required String userId,
    required String itemId,
    required String interactionType,
    double? rating,
    Map<String, dynamic>? context,
  });

  /// Get recommendation statistics for analytics
  Future<Either<Failure, Map<String, dynamic>>> getRecommendationStats({
    required String userId,
  });
}

