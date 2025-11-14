import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_flagged_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_all_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/approve_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/flag_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/remove_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/dismiss_flagged_review_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_state.dart';

class AdminReviewManagementBloc
    extends Bloc<AdminReviewManagementEvent, AdminReviewManagementState> {
  final GetFlaggedReviewsUseCase getFlaggedReviewsUseCase;
  final GetAllReviewsUseCase getAllReviewsUseCase;
  final ApproveReviewUseCase approveReviewUseCase;
  final FlagReviewUseCase flagReviewUseCase;
  final RemoveReviewUseCase removeReviewUseCase;
  final DismissFlaggedReviewUseCase dismissFlaggedReviewUseCase;

  AdminReviewManagementBloc({
    required this.getFlaggedReviewsUseCase,
    required this.getAllReviewsUseCase,
    required this.approveReviewUseCase,
    required this.flagReviewUseCase,
    required this.removeReviewUseCase,
    required this.dismissFlaggedReviewUseCase,
  }) : super(const AdminReviewManagementInitial()) {
    on<LoadFlaggedReviews>(_onLoadFlaggedReviews);
    on<LoadAllReviews>(_onLoadAllReviews);
    on<ApproveReview>(_onApproveReview);
    on<FlagReview>(_onFlagReview);
    on<RemoveReview>(_onRemoveReview);
    on<DismissFlaggedReview>(_onDismissFlaggedReview);
    on<RefreshReviews>(_onRefreshReviews);
  }

  Future<void> _onLoadFlaggedReviews(
    LoadFlaggedReviews event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    emit(const AdminReviewManagementLoading());
    final result = await getFlaggedReviewsUseCase(
      GetFlaggedReviewsParams(
        status: event.status,
        limit: event.limit,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadAllReviews(
    LoadAllReviews event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    emit(const AdminReviewManagementLoading());
    final result = await getAllReviewsUseCase(
      GetAllReviewsParams(
        vendorId: event.vendorId,
        flaggedOnly: event.flaggedOnly,
        limit: event.limit,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }

  Future<void> _onApproveReview(
    ApproveReview event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    final result = await approveReviewUseCase(
      ApproveReviewParams(
        reviewId: event.reviewId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (_) => emit(ReviewOperationSuccess('Review approved successfully')),
    );
  }

  Future<void> _onFlagReview(
    FlagReview event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    final result = await flagReviewUseCase(
      FlagReviewParams(
        reviewId: event.reviewId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (_) => emit(ReviewOperationSuccess('Review flagged successfully')),
    );
  }

  Future<void> _onRemoveReview(
    RemoveReview event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    final result = await removeReviewUseCase(
      RemoveReviewParams(
        reviewId: event.reviewId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (_) => emit(ReviewOperationSuccess('Review removed successfully')),
    );
  }

  Future<void> _onDismissFlaggedReview(
    DismissFlaggedReview event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    final result = await dismissFlaggedReviewUseCase(
      DismissFlaggedReviewParams(
        reviewId: event.reviewId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminReviewManagementError(failure.message)),
      (_) => emit(ReviewOperationSuccess('Flagged review dismissed')),
    );
  }

  Future<void> _onRefreshReviews(
    RefreshReviews event,
    Emitter<AdminReviewManagementState> emit,
  ) async {
    // Reload flagged reviews by default
    add(const LoadFlaggedReviews());
  }
}

