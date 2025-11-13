import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';

/// Use case for flagging a review
class FlagReviewUseCase {
  final ReviewRepository repository;

  FlagReviewUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String reviewId,
    required String reason,
    String? reportedBy,
  }) async {
    return await repository.flagReview(
      reviewId: reviewId,
      reason: reason,
      reportedBy: reportedBy,
    );
  }
}
