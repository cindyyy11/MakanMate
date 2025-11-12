import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/food/domain/entities/food_entity.dart';

/// Repository interface for food items (Domain layer)
abstract class FoodRepository {
  /// Get food item by ID
  Future<Either<Failure, FoodEntity>> getFoodItem(String itemId);

  /// Get all food items
  Future<Either<Failure, List<FoodEntity>>> getAllFoodItems({
    int limit = 10000,
  });

  /// Get food items by restaurant
  Future<Either<Failure, List<FoodEntity>>> getFoodItemsByRestaurant(
    String restaurantId,
  );

  /// Get food items by categories
  Future<Either<Failure, List<FoodEntity>>> getFoodItemsByCategories(
    List<String> categories,
  );

  /// Get food items by cuisine type
  Future<Either<Failure, List<FoodEntity>>> getFoodItemsByCuisine(
    String cuisineType,
  );

  /// Get popular food items
  Future<Either<Failure, List<FoodEntity>>> getPopularItems({int limit = 50});

  /// Get highly rated items
  Future<Either<Failure, List<FoodEntity>>> getHighlyRatedItems({
    int limit = 50,
  });

  /// Get nearby food items
  Future<Either<Failure, List<FoodEntity>>> getNearbyFoodItems(
    Location userLocation, {
    double radiusKm = 10.0,
    int limit = 100,
  });

  /// Get contextual food items (based on time, weather, etc.)
  Future<Either<Failure, List<FoodEntity>>> getContextualItems(
    Map<String, dynamic> context,
    Location userLocation,
  );

  /// Search food items
  Future<Either<Failure, List<FoodEntity>>> searchFoodItems(String query);

  /// Get candidate items for recommendations
  Future<Either<Failure, List<FoodEntity>>> getCandidateItems(String userId);
}
