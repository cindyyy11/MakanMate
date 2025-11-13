import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';

class ReplyToReviewUseCase {
  final ReviewRepository repository;
  const ReplyToReviewUseCase(this.repository);

  Future<void> call({
    required String reviewId,
    required String replyText,
  }) {
    return repository.replyToReview(reviewId: reviewId, replyText: replyText);
  }
}


