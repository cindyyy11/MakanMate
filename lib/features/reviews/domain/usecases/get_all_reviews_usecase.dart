import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

class GetAllReviewsUseCase {
  final AdminReviewRepository repository;

  GetAllReviewsUseCase(this.repository);

  Future<Either<Failure, List<AdminReviewEntity>>> call(
    GetAllReviewsParams params,
  ) async {
    return await repository.getAllReviews(
      vendorId: params.vendorId,
      flaggedOnly: params.flaggedOnly,
      limit: params.limit,
    );
  }
}

class GetAllReviewsParams {
  final String? vendorId;
  final bool? flaggedOnly;
  final int? limit;

  GetAllReviewsParams({this.vendorId, this.flaggedOnly, this.limit});
}

