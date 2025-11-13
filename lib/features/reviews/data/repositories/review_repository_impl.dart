import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';
import 'package:makan_mate/services/activity_log_service.dart';
import 'package:makan_mate/services/notification_service.dart';
import 'package:logger/logger.dart';

/// Implementation of ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.logger,
  });

  @override
  Future<Either<Failure, ReviewEntity>> submitReview({
    required String userId,
    required String userName,
    required String restaurantId,
    required String itemId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final review = await remoteDataSource.submitReview(
        userId: userId,
        userName: userName,
        restaurantId: restaurantId,
        itemId: itemId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
        aspectRatings: aspectRatings,
        tags: tags,
      );

      // ✅ Call infrastructure services from Repository (Data layer)
      await ActivityLogService().logReviewSubmission(
        userId,
        userName,
        restaurantId,
      );

      // Check for inappropriate content (simple keyword check)
      if (comment != null) {
        await _checkAndFlagReview(comment, review.id, restaurantId);
      }

      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(
    String restaurantId, {
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final reviews = await remoteDataSource.getRestaurantReviews(
        restaurantId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getItemReviews(
    String itemId, {
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final reviews = await remoteDataSource.getItemReviews(
        itemId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getUserReviews(
    String userId, {
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final reviews = await remoteDataSource.getUserReviews(
        userId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> flagReview({
    required String reviewId,
    required String reason,
    String? reportedBy,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.flagReview(
        reviewId: reviewId,
        reason: reason,
        reportedBy: reportedBy,
      );

      // ✅ Call infrastructure services from Repository (Data layer)
      await NotificationService().notifyFlaggedReview(reviewId, reason);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markReviewAsHelpful(String reviewId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.markReviewAsHelpful(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Simple keyword check for inappropriate content
  Future<void> _checkAndFlagReview(
    String comment,
    String reviewId,
    String restaurantId,
  ) async {
    try {
      // Simple keyword detection (in production, use ML/NLP)
      final inappropriateKeywords = [
        'spam',
        'fake',
        'scam',
        // Add more keywords as needed
      ];

      final lowerComment = comment.toLowerCase();
      for (var keyword in inappropriateKeywords) {
        if (lowerComment.contains(keyword)) {
          // Auto-flag if contains inappropriate keyword
          logger.w('Potential inappropriate content detected in review');

          // Call remote data source directly to avoid circular dependency
          await remoteDataSource.flagReview(
            reviewId: reviewId,
            reason: 'Auto-flagged: Contains inappropriate content',
            reportedBy: 'system',
          );

          // Notify admin
          await NotificationService().notifyFlaggedReview(
            reviewId,
            'Auto-flagged: Contains inappropriate content',
          );
          break;
        }
      }
    } catch (e) {
      logger.e('Error checking review content: $e');
    }
  }
}
