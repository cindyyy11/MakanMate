import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

abstract class AdminReviewRepository {
  /// Get flagged reviews
  Future<Either<Failure, List<AdminReviewEntity>>> getFlaggedReviews({
    String? status,
    int? limit,
  });

  /// Get all reviews for moderation
  Future<Either<Failure, List<AdminReviewEntity>>> getAllReviews({
    String? vendorId,
    bool? flaggedOnly,
    int? limit,
  });

  /// Approve a review (unflag it)
  Future<Either<Failure, void>> approveReview({
    required String reviewId,
    String? reason,
  });

  /// Flag a review
  Future<Either<Failure, void>> flagReview({
    required String reviewId,
    required String reason,
  });

  /// Remove a review
  Future<Either<Failure, void>> removeReview({
    required String reviewId,
    required String reason,
  });

  /// Dismiss a flagged review (mark as false positive - unflag it)
  Future<Either<Failure, void>> dismissFlaggedReview({
    required String reviewId,
    String? reason,
  });
}

