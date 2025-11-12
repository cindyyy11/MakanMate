import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';

/// Base class for review states
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReviewInitial extends ReviewState {}

/// Loading state
class ReviewLoading extends ReviewState {}

/// Loaded state with reviews
class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

/// Review submitted successfully
class ReviewSubmitted extends ReviewState {
  final ReviewEntity review;

  const ReviewSubmitted(this.review);

  @override
  List<Object> get props => [review];
}

/// Error state
class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

/// Review flagged successfully
class ReviewFlagged extends ReviewState {}

/// Review marked as helpful
class ReviewMarkedAsHelpful extends ReviewState {}

/// Review deleted successfully
class ReviewDeleted extends ReviewState {}
