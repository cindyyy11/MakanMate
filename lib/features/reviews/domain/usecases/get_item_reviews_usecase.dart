import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';

/// Use case for getting item reviews
class GetItemReviewsUseCase {
  final ReviewRepository repository;

  GetItemReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(
    GetItemReviewsParams params,
  ) async {
    return await repository.getItemReviews(params.itemId, limit: params.limit);
  }
}

/// Parameters for getting item reviews
class GetItemReviewsParams extends Equatable {
  final String itemId;
  final int limit;

  const GetItemReviewsParams({required this.itemId, this.limit = 50});

  @override
  List<Object> get props => [itemId, limit];
}
