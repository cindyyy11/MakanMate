import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';

class ApproveReviewUseCase {
  final AdminReviewRepository repository;

  ApproveReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(ApproveReviewParams params) async {
    return await repository.approveReview(
      reviewId: params.reviewId,
      reason: params.reason,
    );
  }
}

class ApproveReviewParams {
  final String reviewId;
  final String? reason;

  ApproveReviewParams({required this.reviewId, this.reason});
}

