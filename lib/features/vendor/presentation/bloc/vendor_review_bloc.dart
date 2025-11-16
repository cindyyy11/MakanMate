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

    await _subscription?.cancel();

    try {
      _subscription = watchReviews(event.vendorId).listen(
        (reviews) {
          add(_ReviewsUpdated(reviews));
        },
        onError: (error) {
          emit(VendorReviewError("Failed to load reviews: $error"));
        },
      );
    } catch (e) {
      emit(VendorReviewError("Error loading reviews: $e"));
    }
  }

  Future<void> _onReply(
    ReplyToVendorReview event,
    Emitter<VendorReviewState> emit,
  ) async {
    final current = state is VendorReviewLoaded
        ? (state as VendorReviewLoaded).reviews
        : <ReviewEntity>[];

    emit(VendorReviewActionInProgress(current));

    try {
      await replyToReview.call(
        reviewId: event.reviewId,
        replyText: event.replyText,
      );
      // Stream will auto-update
    } catch (e) {
      emit(VendorReviewError("Failed to send reply: $e"));
    }
  }

  Future<void> _onReport(
    ReportVendorReview event,
    Emitter<VendorReviewState> emit,
  ) async {
    final current = state is VendorReviewLoaded
        ? (state as VendorReviewLoaded).reviews
        : <ReviewEntity>[];

    emit(VendorReviewActionInProgress(current));

    try {
      await reportReview.call(
        reviewId: event.reviewId,
        reason: event.reason,
      );

      emit(VendorReviewLoaded(current)); // Keep current UI
    } catch (e) {
      emit(VendorReviewError("Failed to report review: $e"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _ReviewsUpdated extends VendorReviewEvent {
  final List<ReviewEntity> reviews;

  const _ReviewsUpdated(this.reviews);

  @override
  List<Object?> get props => [reviews];
}
