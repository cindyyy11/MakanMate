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
  }

  void _onLoadReviews(
    LoadVendorReviews event,
    Emitter<VendorReviewState> emit,
  ) {
    emit(VendorReviewLoading());
    _subscription?.cancel();
    _subscription = watchReviews(event.restaurantId).listen(
      (reviews) => emit(VendorReviewLoaded(reviews)),
      onError: (e) => emit(VendorReviewError(e.toString())),
    );
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
      // Stream will automatically update, so we don't need to manually emit
      // The state will be updated by the stream listener
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
      // Report doesn't change the review, so we can go back to loaded state
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


