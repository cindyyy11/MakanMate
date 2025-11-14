import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';

/// Use case for submitting a review
class SubmitReviewUseCase {
  final ReviewRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call({
    required String userId,
    required String userName,
    required String vendorId,
    required String itemId,
    String? outletId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
  }) async {
    return await repository.submitReview(
      userId: userId,
      userName: userName,
      vendorId: vendorId,
      itemId: itemId,
      outletId: outletId,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
      aspectRatings: aspectRatings,
      tags: tags,
    );
  }
}
