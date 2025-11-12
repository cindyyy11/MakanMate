import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/vendor/domain/entities/review_entity.dart';

abstract class VendorReviewState extends Equatable {
  const VendorReviewState();
  @override
  List<Object?> get props => [];
}

class VendorReviewInitial extends VendorReviewState {}

class VendorReviewLoading extends VendorReviewState {}

class VendorReviewLoaded extends VendorReviewState {
  final List<ReviewEntity> reviews;
  const VendorReviewLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class VendorReviewError extends VendorReviewState {
  final String message;
  const VendorReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorReviewActionInProgress extends VendorReviewState {
  final List<ReviewEntity> current;
  const VendorReviewActionInProgress(this.current);
  @override
  List<Object?> get props => [current];
}


