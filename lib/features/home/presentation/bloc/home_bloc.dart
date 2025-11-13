import 'package:bloc/bloc.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurant_details_usecase.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRestaurantsUseCase getRestaurants;
  final GetRestaurantDetailsUseCase getRestaurantDetails;

  HomeBloc({required this.getRestaurants, required this.getRestaurantDetails})
    : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      // 1. Get all restaurants
      final restaurants = await getRestaurants();

      // 2. Build categories
      final categories = _buildCuisineCategories(await restaurants);

      // 3. Recommendations (for now same)
      final recommendations = restaurants;

      emit(
        HomeLoaded(
          categories: categories,
          recommendations: await recommendations,
          restaurants: await restaurants,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  List<RestaurantEntity> _buildCuisineCategories(
    List<RestaurantEntity> allRestaurants,
  ) {
    final seen = <String>{};
    final result = <RestaurantEntity>[];

    for (final r in allRestaurants) {
      final cuisine = r.cuisine?.trim();
      if (cuisine == null || cuisine.isEmpty) continue;

      if (!seen.contains(cuisine)) {
        seen.add(cuisine);
        result.add(r);
      }
    }

    if (result.isEmpty) {
      return allRestaurants.length > 8
          ? allRestaurants.sublist(0, 8)
          : allRestaurants;
    }

    return result;
  }
}
