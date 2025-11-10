import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:makan_mate/features/recommendations/data/models/recommendation_models.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Implementation of the recommendation repository
/// 
/// Coordinates between local cache and remote data sources
class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;
  final RecommendationLocalDataSource localDataSource;
  final Logger logger;

  RecommendationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.logger,
  });

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations({
    required String userId,
    int limit = 10,
    RecommendationContextEntity? context,
  }) async {
    try {
      logger.i('Getting recommendations for user: $userId');

      // Try to get from cache first
      final isCacheValid = await localDataSource.isCacheValid(userId);
      
      if (isCacheValid) {
        logger.i('Using cached recommendations');
        final cachedRecs = await localDataSource.getCachedRecommendations(userId);
        if (cachedRecs.isNotEmpty) {
          return Right(_mapToEntities(cachedRecs));
        }
      }

      // Fetch from remote
      logger.i('Fetching fresh recommendations');
      final recommendationContext = context != null 
          ? _mapToModel(context) 
          : null;

      final recommendations = await remoteDataSource.getRecommendations(
        userId: userId,
        limit: limit,
        context: recommendationContext,
      );

      // Cache the results
      await localDataSource.cacheRecommendations(userId, recommendations);

      logger.i('Successfully retrieved ${recommendations.length} recommendations');
      return Right(_mapToEntities(recommendations));
    } on Exception catch (e) {
      logger.e('Error getting recommendations: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error getting recommendations: $e');
      return Left(ServerFailure('Failed to get recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getContextualRecommendations({
    required String userId,
    required RecommendationContextEntity context,
    int limit = 10,
  }) async {
    try {
      logger.i('Getting contextual recommendations for user: $userId');

      final recommendationContext = _mapToModel(context);

      final recommendations = await remoteDataSource.getContextualRecommendations(
        userId: userId,
        context: recommendationContext,
        limit: limit,
      );

      logger.i('Successfully retrieved ${recommendations.length} contextual recommendations');
      return Right(_mapToEntities(recommendations));
    } on Exception catch (e) {
      logger.e('Error getting contextual recommendations: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error getting contextual recommendations: $e');
      return Left(ServerFailure('Failed to get contextual recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getSimilarItems({
    required String itemId,
    int limit = 10,
  }) async {
    try {
      logger.i('Getting similar items for: $itemId');

      final recommendations = await remoteDataSource.getSimilarItems(
        itemId: itemId,
        limit: limit,
      );

      logger.i('Successfully retrieved ${recommendations.length} similar items');
      return Right(_mapToEntities(recommendations));
    } on Exception catch (e) {
      logger.e('Error getting similar items: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error getting similar items: $e');
      return Left(ServerFailure('Failed to get similar items: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> refreshRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      logger.i('Refreshing recommendations for user: $userId');

      // Clear cache
      await localDataSource.clearCache(userId);

      // Fetch fresh recommendations
      final recommendations = await remoteDataSource.getRecommendations(
        userId: userId,
        limit: limit,
      );

      // Cache the new results
      await localDataSource.cacheRecommendations(userId, recommendations);

      logger.i('Successfully refreshed ${recommendations.length} recommendations');
      return Right(_mapToEntities(recommendations));
    } on Exception catch (e) {
      logger.e('Error refreshing recommendations: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error refreshing recommendations: $e');
      return Left(ServerFailure('Failed to refresh recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> trackInteraction({
    required String userId,
    required String itemId,
    required String interactionType,
    double? rating,
    Map<String, dynamic>? context,
  }) async {
    try {
      logger.i('Tracking interaction: $userId -> $itemId ($interactionType)');

      await remoteDataSource.trackInteraction(
        userId: userId,
        itemId: itemId,
        interactionType: interactionType,
        rating: rating,
        context: context,
      );

      // Invalidate cache to get updated recommendations
      await localDataSource.clearCache(userId);

      logger.i('Successfully tracked interaction');
      return const Right(null);
    } on Exception catch (e) {
      logger.e('Error tracking interaction: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error tracking interaction: $e');
      return Left(ServerFailure('Failed to track interaction: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRecommendationStats({
    required String userId,
  }) async {
    try {
      logger.i('Getting recommendation stats for user: $userId');

      final stats = await remoteDataSource.getRecommendationStats(
        userId: userId,
      );

      logger.i('Successfully retrieved recommendation stats');
      return Right(stats);
    } on Exception catch (e) {
      logger.e('Error getting recommendation stats: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      logger.e('Unexpected error getting recommendation stats: $e');
      return Left(ServerFailure('Failed to get recommendation stats: $e'));
    }
  }

  /// Map data models to domain entities
  List<RecommendationEntity> _mapToEntities(List<RecommendationItem> models) {
    return models.map((model) => RecommendationEntity(
      itemId: model.itemId,
      score: model.score,
      reason: model.reason,
      algorithmType: model.algorithmType,
      confidence: model.confidence,
      metadata: model.metadata,
      generatedAt: model.generatedAt,
    )).toList();
  }

  /// Map context entity to context model
  RecommendationContext _mapToModel(RecommendationContextEntity entity) {
    return RecommendationContext(
      userId: entity.userId,
      timestamp: entity.timestamp,
      timeOfDay: entity.timeOfDay,
      dayOfWeek: entity.dayOfWeek,
      weather: entity.weather,
      temperature: entity.temperature,
      currentLocation: entity.currentLocation != null
          ? Location(
              latitude: entity.currentLocation!.latitude,
              longitude: entity.currentLocation!.longitude,
              address: entity.currentLocation!.address,
            )
          : null,
      occasion: entity.occasion,
      groupSize: entity.groupSize,
    );
  }
}

