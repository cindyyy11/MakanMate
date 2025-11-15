import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/reviews/data/datasources/user_review_remote_datasource.dart';
import 'package:makan_mate/features/reviews/data/models/review_model.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/user_review_repository.dart';

class UserReviewRepositoryImpl implements UserReviewRepository {
  final UserReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ReviewEntity>> submitReview(ReviewEntity review) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure("No internet connection"));
    }

    try {
      final model = ReviewModel(
        id: review.id,
        userId: review.userId,
        itemId: review.itemId,
        vendorId: review.vendorId,
        outletId: review.outletId,
        rating: review.rating,
        comment: review.comment,
        imageUrls: review.imageUrls,
        aspectRatings: review.aspectRatings,
        tags: review.tags,
        helpfulCount: review.helpfulCount,
        createdAt: review.createdAt,
        updatedAt: review.updatedAt,
      );

      final savedModel = await remoteDataSource.submitReview(model);

      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure("Failed to submit review: $e"));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getUserReviews(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure("No internet connection"));
    }

    try {
      final models = await remoteDataSource.getUserReviews(userId);

      final entities = models.map((m) => m.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure("Failed to load user reviews: $e"));
    }
  }
}
