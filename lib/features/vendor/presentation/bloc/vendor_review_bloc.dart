import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/vendor/domain/entities/review_entity.dart';
import 'package:makan_mate/features/vendor/domain/usecases/reply_to_review_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/report_review_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/watch_vendor_reviews_usecase.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_review_event.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_review_state.dart';

class VendorReviewBloc extends Bloc<VendorReviewEvent, VendorReviewState> {
  final WatchVendorReviewsUseCase watchReviews;
  final ReplyToReviewUseCase replyToReview;
  final ReportReviewUseCase reportReview;

  StreamSubscription<List<ReviewEntity>>? _subscription;

  VendorReviewBloc({
    required this.watchReviews,
    required this.replyToReview,
    required this.reportReview,
  }) : super(VendorReviewInitial()) {
    on<LoadVendorReviews>(_onLoadReviews);
    on<ReplyToVendorReview>(_onReply);
    on<ReportVendorReview>(_onReport);
    on<_ReviewsUpdated>(_onReviewsUpdated);
  }

  // Internal event to update reviews
  void _onReviewsUpdated(
    _ReviewsUpdated event,
    Emitter<VendorReviewState> emit,
  ) {
    emit(VendorReviewLoaded(event.reviews));
  }

  Future<void> _onLoadReviews(
    LoadVendorReviews event,
    Emitter<VendorReviewState> emit,
  ) async {
    emit(VendorReviewLoading());
    
    // Cancel previous subscription
    await _subscription?.cancel();

    try {
      // Subscribe to the stream and emit updates via internal event
      _subscription = watchReviews(event.vendorId).listen(
        (reviews) {
          // Use add() to trigger internal event instead of emit()
          add(_ReviewsUpdated(reviews));
        },
        onError: (error, stackTrace) {
          add(_ReviewsUpdated(const [])); // Emit empty list on error
        },
      );
    } catch (e, stackTrace) {
      emit(VendorReviewError(e.toString()));
    }
  }

  Future<void> _onReply(
    ReplyToVendorReview event,
    Emitter<VendorReviewState> emit,
  ) async {
    final current =
        state is VendorReviewLoaded ? (state as VendorReviewLoaded).reviews : <ReviewEntity>[];
    emit(VendorReviewActionInProgress(current));
    try {
      await replyToReview(reviewId: event.reviewId, replyText: event.replyText);
      // The stream will automatically update with the new reply
    } catch (e) {
      emit(VendorReviewError(e.toString()));
    }
  }

  Future<void> _onReport(
    ReportVendorReview event,
    Emitter<VendorReviewState> emit,
  ) async {
    final current =
        state is VendorReviewLoaded ? (state as VendorReviewLoaded).reviews : <ReviewEntity>[];
    emit(VendorReviewActionInProgress(current));
    try {
      await reportReview(reviewId: event.reviewId, reason: event.reason);
      if (current.isNotEmpty) {
        emit(VendorReviewLoaded(current));
      }
    } catch (e) {
      emit(VendorReviewError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

// Internal event for stream updates
class _ReviewsUpdated extends VendorReviewEvent {
  final List<ReviewEntity> reviews;

  const _ReviewsUpdated(this.reviews);

  @override
  List<Object?> get props => [reviews];
}