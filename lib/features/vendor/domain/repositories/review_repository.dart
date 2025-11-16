import 'package:makan_mate/features/vendor/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Stream<List<ReviewEntity>> watchRestaurantReviews(String restaurantId);

  Future<void> replyToReview({
    required String reviewId,
    required String replyText,
  });

  Future<void> reportReview({
    required String reviewId,
    required String reason,
  });

  Future<ReviewEntity?> getLatestReview(String vendorId);
}
