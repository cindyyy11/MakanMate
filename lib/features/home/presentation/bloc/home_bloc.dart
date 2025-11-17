import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurant_details_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_personalized_restaurants_usecase.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRestaurantsUseCase getRestaurants;
  final GetRestaurantDetailsUseCase getRestaurantDetails;
  final GetPersonalizedRestaurantsUseCase getPersonalizedRestaurants;

  HomeBloc({
    required this.getRestaurants,
    required this.getRestaurantDetails,
    required this.getPersonalizedRestaurants,
  }) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      /// 1. Load all restaurants
      final restaurants = await getRestaurants();

      print(restaurants.runtimeType);


      /// 2. Build category list from cuisine
      final categories = _buildCuisineCategories(restaurants);

      /// 3. Prepare recommendation list
      List<RestaurantEntity> recommendations;
      bool personalized = false;

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

          final prefs = (doc.data()?["dietaryPreferences"] ?? {})
              as Map<String, dynamic>;

          if (prefs.isNotEmpty) {
            final personalizedList =
                await getPersonalizedRestaurants(prefs);

            if (personalizedList.isNotEmpty) {
              recommendations = personalizedList;
              personalized = true;
            } else {
              // fallback
              final fallback = List<RestaurantEntity>.from(restaurants);
              fallback.shuffle();
              recommendations = fallback;
            }
          } else {
            // No prefs saved
            final fallback = List<RestaurantEntity>.from(restaurants);
            fallback.shuffle();
            recommendations = fallback;
          }
        } else {
          // Not logged in
          final fallback = List<RestaurantEntity>.from(restaurants);
          fallback.shuffle();
          recommendations = fallback;
        }
      } catch (_) {
        // Personalization failed → fallback
        final fallback = List<RestaurantEntity>.from(restaurants);
        fallback.shuffle();
        recommendations = fallback;
      }

      emit(
        HomeLoaded(
          categories: categories,
          recommendations: recommendations,
          restaurants: restaurants,
          isPersonalized: personalized,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  List<RestaurantEntity> _buildCuisineCategories(
    List<RestaurantEntity> allRestaurants,
  ) {
    final result = <RestaurantEntity>[];
    final seen = <String>{};

    for (final r in allRestaurants) {
      final cuisine = r.cuisineType?.trim();
      if (cuisine == null || cuisine.isEmpty) continue;

      if (!seen.contains(cuisine)) {
        seen.add(cuisine);
        result.add(r);
      }
    }

    if (result.isEmpty) {
      return allRestaurants.length >= 8
          ? allRestaurants.sublist(0, 8)
          : allRestaurants;
    }

    return result;
  }
}
