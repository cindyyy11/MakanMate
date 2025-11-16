import 'package:equatable/equatable.dart';

abstract class VendorReviewEvent extends Equatable {
  const VendorReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorReviews extends VendorReviewEvent {
  final String vendorId;
  const LoadVendorReviews(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
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
