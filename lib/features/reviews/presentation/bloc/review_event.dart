import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// User submits a new review (restaurant or menu)
class SubmitReviewEvent extends ReviewEvent {
  final ReviewEntity review;

  const SubmitReviewEvent(this.review);

  @override
  List<Object?> get props => [review];
}
