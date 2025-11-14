import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

abstract class AdminReviewManagementState extends Equatable {
  const AdminReviewManagementState();

  @override
  List<Object?> get props => [];
}

class AdminReviewManagementInitial extends AdminReviewManagementState {
  const AdminReviewManagementInitial();
}

class AdminReviewManagementLoading extends AdminReviewManagementState {
  const AdminReviewManagementLoading();
}

class ReviewsLoaded extends AdminReviewManagementState {
  final List<AdminReviewEntity> reviews;

  const ReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class AdminReviewManagementError extends AdminReviewManagementState {
  final String message;

  const AdminReviewManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewOperationSuccess extends AdminReviewManagementState {
  final String message;

  const ReviewOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

