import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_review_management_datasource.dart';

/// Use case to approve a review (unflag it)
class ApproveReviewUseCase {
  final AdminReviewManagementDataSource dataSource;

  ApproveReviewUseCase(this.dataSource);

  Future<Either<Failure, void>> call(ApproveReviewParams params) async {
    try {
      await dataSource.approveReview(
        reviewId: params.reviewId,
        reason: params.reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ApproveReviewParams {
  final String reviewId;
  final String? reason;

  ApproveReviewParams({required this.reviewId, this.reason});
}

