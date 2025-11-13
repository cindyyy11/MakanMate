import 'package:makan_mate/features/vendor/domain/entities/review_entity.dart';
import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';

class WatchVendorReviewsUseCase {
  final ReviewRepository repository;
  const WatchVendorReviewsUseCase(this.repository);

  Stream<List<ReviewEntity>> call(String restaurantId) {
    return repository.watchRestaurantReviews(restaurantId);
  }
}


