import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/user_review_repository.dart';

class SubmitUserReviewUseCase {
  final UserReviewRepository repository;

  SubmitUserReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call(ReviewEntity review) async {
    return repository.submitReview(review);
  }
}
