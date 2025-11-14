import 'package:makan_mate/features/ratings/domain/entities/rating_entity.dart';

abstract class RatingsRepository {
  Future<void> submitRating(RatingEntity rating);
}
