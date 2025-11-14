import '../entities/rating_entity.dart';
import '../repositories/ratings_repository.dart';

class SubmitRatingUsecase {
  final RatingsRepository repository;

  SubmitRatingUsecase(this.repository);

  Future<void> call(RatingEntity rating) {
    return repository.submitRating(rating);
  }
}
