import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_review_management_datasource.dart';

/// Use case to remove a review
class RemoveReviewUseCase {
  final AdminReviewManagementDataSource dataSource;

  RemoveReviewUseCase(this.dataSource);

  Future<Either<Failure, void>> call(RemoveReviewParams params) async {
    try {
      await dataSource.removeReview(
        reviewId: params.reviewId,
        reason: params.reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class RemoveReviewParams {
  final String reviewId;
  final String reason;

  RemoveReviewParams({required this.reviewId, required this.reason});
}

