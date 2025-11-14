import 'package:equatable/equatable.dart';

abstract class AdminReviewManagementEvent extends Equatable {
  const AdminReviewManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlaggedReviews extends AdminReviewManagementEvent {
  final String? status;
  final int? limit;

  const LoadFlaggedReviews({this.status, this.limit});

  @override
  List<Object?> get props => [status, limit];
}

class LoadAllReviews extends AdminReviewManagementEvent {
  final String? vendorId;
  final bool? flaggedOnly;
  final int? limit;

  const LoadAllReviews({this.vendorId, this.flaggedOnly, this.limit});

  @override
  List<Object?> get props => [vendorId, flaggedOnly, limit];
}

class ApproveReview extends AdminReviewManagementEvent {
  final String reviewId;
  final String? reason;

  const ApproveReview({required this.reviewId, this.reason});

  @override
  List<Object?> get props => [reviewId, reason];
}

class FlagReview extends AdminReviewManagementEvent {
  final String reviewId;
  final String reason;

  const FlagReview({required this.reviewId, required this.reason});

  @override
  List<Object?> get props => [reviewId, reason];
}

class RemoveReview extends AdminReviewManagementEvent {
  final String reviewId;
  final String reason;

  const RemoveReview({required this.reviewId, required this.reason});

  @override
  List<Object?> get props => [reviewId, reason];
}

class DismissFlaggedReview extends AdminReviewManagementEvent {
  final String reviewId;
  final String? reason;

  const DismissFlaggedReview({required this.reviewId, this.reason});

  @override
  List<Object?> get props => [reviewId, reason];
}

class RefreshReviews extends AdminReviewManagementEvent {
  const RefreshReviews();
}

