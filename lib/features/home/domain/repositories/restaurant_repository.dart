import '../entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantEntity>> getCategories();
  Future<List<RestaurantEntity>> getRecommendations();
}
