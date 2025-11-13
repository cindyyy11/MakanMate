import 'package:equatable/equatable.dart';

abstract class VendorReviewEvent extends Equatable {
  const VendorReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorReviews extends VendorReviewEvent {
  final String restaurantId;
  const LoadVendorReviews(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class ReplyToVendorReview extends VendorReviewEvent {
  final String reviewId;
  final String replyText;
  const ReplyToVendorReview(this.reviewId, this.replyText);
  @override
  List<Object?> get props => [reviewId, replyText];
}

class ReportVendorReview extends VendorReviewEvent {
  final String reviewId;
  final String reason;
  const ReportVendorReview(this.reviewId, this.reason);
  @override
  List<Object?> get props => [reviewId, reason];
}


