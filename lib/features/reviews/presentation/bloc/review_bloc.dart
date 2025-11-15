import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/reviews/domain/usecases/submit_user_review_usecase.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_event.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SubmitUserReviewUseCase submitUserReviewUseCase;

  ReviewBloc(this.submitUserReviewUseCase) : super(ReviewInitial()) {
    on<SubmitReviewEvent>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final review = event.review;

    final result = await submitUserReviewUseCase(review);

    result.fold(
      (failure) => emit(ReviewFailure(failure.message)),
      (_) => emit(ReviewSuccess()),
    );
  }
}
