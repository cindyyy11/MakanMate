import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';

/// Use case for getting vendor reviews (restaurant reviews)
class GetRestaurantReviewsUseCase {
  final ReviewRepository repository;

  GetRestaurantReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(
    GetRestaurantReviewsParams params,
  ) async {
    return await repository.getRestaurantReviews(
      params.vendorId,
      limit: params.limit,
    );
  }
}

/// Parameters for getting vendor reviews
class GetRestaurantReviewsParams extends Equatable {
  final String vendorId;
  final int limit;

  const GetRestaurantReviewsParams({
    required this.vendorId,
    this.limit = 50,
  });

  @override
  List<Object> get props => [vendorId, limit];
}
