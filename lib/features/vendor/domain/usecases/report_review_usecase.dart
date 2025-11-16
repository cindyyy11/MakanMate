import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';

class ReportReviewUseCase {
  final ReviewRepository repository;

  ReportReviewUseCase(this.repository);

  Future<void> call({
    required String reviewId,
    required String reason,
  }) async {
    return repository.reportReview(
      reviewId: reviewId,
      reason: reason,
    );
  }
}
