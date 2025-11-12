import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';

class ReportReviewUseCase {
  final ReviewRepository repository;
  const ReportReviewUseCase(this.repository);

  Future<void> call({
    required String reviewId,
    required String reason,
  }) {
    return repository.reportReview(reviewId: reviewId, reason: reason);
  }
}


