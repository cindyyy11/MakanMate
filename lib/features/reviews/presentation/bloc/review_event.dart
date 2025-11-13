import 'package:equatable/equatable.dart';

/// Base class for review events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit a review
class SubmitReviewEvent extends ReviewEvent {
  final String userId;
  final String userName;
  final String restaurantId;
  final String itemId;
  final double rating;
  final String? comment;
  final List<String>? imageUrls;
  final Map<String, double>? aspectRatings;
  final List<String>? tags;

  const SubmitReviewEvent({
    required this.userId,
    required this.userName,
    required this.restaurantId,
    required this.itemId,
    required this.rating,
    this.comment,
    this.imageUrls,
    this.aspectRatings,
    this.tags,
  });

  @override
  List<Object?> get props => [
    userId,
    userName,
    restaurantId,
    itemId,
    rating,
    comment,
    imageUrls,
    aspectRatings,
    tags,
  ];
}

/// Event to get restaurant reviews
class GetRestaurantReviewsEvent extends ReviewEvent {
  final String restaurantId;
  final int limit;

  const GetRestaurantReviewsEvent({
    required this.restaurantId,
    this.limit = 50,
  });

  @override
  List<Object> get props => [restaurantId, limit];
}

/// Event to get item reviews
class GetItemReviewsEvent extends ReviewEvent {
  final String itemId;
  final int limit;

  const GetItemReviewsEvent({required this.itemId, this.limit = 50});

  @override
  List<Object> get props => [itemId, limit];
}

/// Event to flag a review
class FlagReviewEvent extends ReviewEvent {
  final String reviewId;
  final String reason;
  final String? reportedBy;

  const FlagReviewEvent({
    required this.reviewId,
    required this.reason,
    this.reportedBy,
  });

  @override
  List<Object?> get props => [reviewId, reason, reportedBy];
}

/// Event to mark review as helpful
class MarkReviewAsHelpfulEvent extends ReviewEvent {
  final String reviewId;

  const MarkReviewAsHelpfulEvent(this.reviewId);

  @override
  List<Object> get props => [reviewId];
}

/// Event to delete a review
class DeleteReviewEvent extends ReviewEvent {
  final String reviewId;

  const DeleteReviewEvent(this.reviewId);

  @override
  List<Object> get props => [reviewId];
}
