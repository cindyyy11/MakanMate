import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';

abstract class UserReviewRepository {
  Future<Either<Failure, ReviewEntity>> submitReview(ReviewEntity review);
  Future<Either<Failure, List<ReviewEntity>>> getUserReviews(String userId);
}
