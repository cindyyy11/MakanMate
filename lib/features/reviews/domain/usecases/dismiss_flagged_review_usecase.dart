import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';

class DismissFlaggedReviewUseCase {
  final AdminReviewRepository repository;

  DismissFlaggedReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(DismissFlaggedReviewParams params) async {
    return await repository.dismissFlaggedReview(
      reviewId: params.reviewId,
      reason: params.reason,
    );
  }
}

class DismissFlaggedReviewParams {
  final String reviewId;
  final String? reason;

  DismissFlaggedReviewParams({required this.reviewId, this.reason});
}

