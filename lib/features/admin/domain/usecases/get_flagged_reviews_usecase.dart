import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_review_management_datasource.dart';

/// Use case to get flagged reviews
class GetFlaggedReviewsUseCase {
  final AdminReviewManagementDataSource dataSource;

  GetFlaggedReviewsUseCase(this.dataSource);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetFlaggedReviewsParams params,
  ) async {
    try {
      final reviews = await dataSource.getFlaggedReviews(
        status: params.status,
        limit: params.limit,
      );
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetFlaggedReviewsParams {
  final String? status;
  final int? limit;

  GetFlaggedReviewsParams({this.status, this.limit});
}

