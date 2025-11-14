import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';

class RemoveReviewUseCase {
  final AdminReviewRepository repository;

  RemoveReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(RemoveReviewParams params) async {
    return await repository.removeReview(
      reviewId: params.reviewId,
      reason: params.reason,
    );
  }
}

class RemoveReviewParams {
  final String reviewId;
  final String reason;

  RemoveReviewParams({required this.reviewId, required this.reason});
}

