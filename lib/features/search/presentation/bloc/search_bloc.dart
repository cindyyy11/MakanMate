import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/search/domain/usecases/add_search_history_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/get_search_history_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/search_food_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/search_restaurant_usecase.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_event.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRestaurantUsecase searchRestaurantUsecase;
  final SearchFoodUsecase searchFoodUsecase;
  final GetSearchHistoryUsecase getSearchHistoryUsecase;
  final AddSearchHistoryUsecase addSearchHistoryUsecase;

  SearchBloc({
    required this.searchRestaurantUsecase,
    required this.searchFoodUsecase,
    required this.getSearchHistoryUsecase,
    required this.addSearchHistoryUsecase,
  }) : super(SearchState.initial()) {
    on<SearchStarted>(_onStarted);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
    on<SearchSuggestionTapped>(_onSuggestionTapped);
  }

  Future<void> _onStarted(
      SearchStarted event, Emitter<SearchState> emit) async {
    final either = await getSearchHistoryUsecase();
    either.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (history) => emit(state.copyWith(history: history)),
    );
  }

  Future<void> _onQuerySubmitted(
      SearchQuerySubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(
      isLoading: true,
      currentQuery: query,
      errorMessage: null,
    ));

    final restaurantFuture = searchRestaurantUsecase(query);
    final foodFuture = searchFoodUsecase(query);

    final restaurantEither = await restaurantFuture;
    final foodEither = await foodFuture;

    restaurantEither.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: failure.message ?? 'Error')),
      (restaurants) {
        foodEither.fold(
          (failure) => emit(state.copyWith(
              isLoading: false, errorMessage: failure.message ?? 'Error')),
          (foods) {
            emit(state.copyWith(
              isLoading: false,
              restaurants: restaurants,
              foods: foods,
            ));
          },
        );
      },
    );

    // fire and forget add history
    await addSearchHistoryUsecase(query);
    final historyEither = await getSearchHistoryUsecase();
    historyEither.fold(
      (_) {},
      (history) => emit(state.copyWith(history: history)),
    );
  }

  Future<void> _onSuggestionTapped(
      SearchSuggestionTapped event, Emitter<SearchState> emit) async {
    add(SearchQuerySubmitted(event.query));
  }
}
