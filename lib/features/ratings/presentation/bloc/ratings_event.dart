import '../../domain/entities/rating_entity.dart';

abstract class RatingsEvent {}

class SubmitRatingEvent extends RatingsEvent {
  final RatingEntity rating;
  SubmitRatingEvent(this.rating);
}
