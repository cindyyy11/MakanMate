import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/food/domain/entities/food_entity.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';

/// Use case for getting food items by restaurant
class GetFoodItemsByRestaurantUseCase {
  final FoodRepository repository;

  GetFoodItemsByRestaurantUseCase(this.repository);

  Future<Either<Failure, List<FoodEntity>>> call(String restaurantId) async {
    return await repository.getFoodItemsByRestaurant(restaurantId);
  }
}

