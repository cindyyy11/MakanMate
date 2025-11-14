import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_rating_usecase.dart';
import 'ratings_event.dart';
import 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  final SubmitRatingUsecase submitRatingUsecase;

  RatingsBloc(this.submitRatingUsecase) : super(RatingsInitial()) {
    on<SubmitRatingEvent>(_onSubmitRating);
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());
    try {
      await submitRatingUsecase(event.rating);
      emit(RatingsSuccess());
    } catch (e) {
      emit(RatingsFailure(e.toString()));
    }
  }
}
