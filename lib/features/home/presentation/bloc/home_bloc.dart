import 'package:bloc/bloc.dart';
import 'package:makan_mate/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRestaurantsUseCase getRestaurants;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetRecommendationsUseCase getRecommendationsUseCase;

  HomeBloc({
    required this.getRestaurants,
    required this.getCategoriesUseCase,
    required this.getRecommendationsUseCase,
  }) : super(HomeInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<RefreshRestaurants>(_onRefreshRestaurants);
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final categories = await getCategoriesUseCase();
      final recommendations = await getRecommendationsUseCase();
      emit(
        HomeLoaded(
          categories: categories,
          recommendations: recommendations,
          restaurants: [],
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    print('running home bloc');

    final categories = await getCategoriesUseCase();
    final recommendations = await getRecommendationsUseCase();
    final result = await getRestaurants(
      limit: event.limit ?? 20,
      cuisineType: event.cuisineType,
      isHalal: event.isHalal,
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (restaurants) => emit(
        HomeLoaded(
          categories: categories,
          recommendations: recommendations,
          restaurants: restaurants,
        ),
      ),
    );
  }

  Future<void> _onRefreshRestaurants(
    RefreshRestaurants event,
    Emitter<HomeState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;

    final categories = await getCategoriesUseCase();
    final recommendations = await getRecommendationsUseCase();

    final result = await getRestaurants(limit: 20);

    result.fold(
      (failure) {
        // If refresh fails, keep current state and show error
        if (currentState is HomeLoaded) {
          // Could emit a snackbar event here
        } else {
          emit(HomeError(failure.message));
        }
      },
      (restaurants) => emit(
        HomeLoaded(
          categories: categories,
          recommendations: recommendations,
          restaurants: restaurants,
        ),
      ),
    );
  }
}
