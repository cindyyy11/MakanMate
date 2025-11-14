import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';

/// Repository interface for reviews (Domain layer)
abstract class ReviewRepository {
  /// Submit a review
  Future<Either<Failure, ReviewEntity>> submitReview({
    required String userId,
    required String userName,
    required String vendorId,
    required String itemId,
    String? outletId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
  });

  /// Get reviews for a vendor (restaurant)
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(
    String vendorId, {
    int limit = 50,
  });

  /// Get reviews for a food item
  Future<Either<Failure, List<ReviewEntity>>> getItemReviews(
    String itemId, {
    int limit = 50,
  });

  /// Get reviews by user
  Future<Either<Failure, List<ReviewEntity>>> getUserReviews(
    String userId, {
    int limit = 50,
  });

  /// Flag a review
  Future<Either<Failure, void>> flagReview({
    required String reviewId,
    required String reason,
    String? reportedBy,
  });

  /// Mark review as helpful
  Future<Either<Failure, void>> markReviewAsHelpful(String reviewId);

  /// Delete a review
  Future<Either<Failure, void>> deleteReview(String reviewId);
}
