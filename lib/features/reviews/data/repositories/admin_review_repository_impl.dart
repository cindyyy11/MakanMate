import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/reviews/data/datasources/admin_review_management_datasource.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

class AdminReviewRepositoryImpl implements AdminReviewRepository {
  final AdminReviewManagementDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AdminReviewEntity>>> getFlaggedReviews({
    String? status,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final reviews = await remoteDataSource.getFlaggedReviews(
        status: status,
        limit: limit,
      );
      final entities = reviews.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch flagged reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminReviewEntity>>> getAllReviews({
    String? vendorId,
    bool? flaggedOnly,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final reviews = await remoteDataSource.getAllReviews(
        vendorId: vendorId,
        flaggedOnly: flaggedOnly,
        limit: limit,
      );
      final entities = reviews.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveReview({
    required String reviewId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remoteDataSource.approveReview(
        reviewId: reviewId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to approve review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> flagReview({
    required String reviewId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remoteDataSource.flagReview(
        reviewId: reviewId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to flag review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeReview({
    required String reviewId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remoteDataSource.removeReview(
        reviewId: reviewId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to remove review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dismissFlaggedReview({
    required String reviewId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remoteDataSource.dismissFlaggedReview(
        reviewId: reviewId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to dismiss flagged review: $e'));
    }
  }
}

