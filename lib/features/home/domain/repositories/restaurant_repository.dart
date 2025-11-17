import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantEntity>> getRestaurants();
  Future<RestaurantEntity> getRestaurantById(String id);

  Future<List<RestaurantEntity>> getPersonalizedRestaurants(
    Map<String, dynamic> dietaryPrefs,
  );
}
