import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

class GetFlaggedReviewsUseCase {
  final AdminReviewRepository repository;

  GetFlaggedReviewsUseCase(this.repository);

  Future<Either<Failure, List<AdminReviewEntity>>> call(
    GetFlaggedReviewsParams params,
  ) async {
    return await repository.getFlaggedReviews(
      status: params.status,
      limit: params.limit,
    );
  }
}

class GetFlaggedReviewsParams {
  final String? status;
  final int? limit;

  GetFlaggedReviewsParams({this.status, this.limit});
}

