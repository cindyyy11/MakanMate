import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/food/domain/entities/food_entity.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';

/// Use case for getting a food item by ID
class GetFoodItemUseCase {
  final FoodRepository repository;

  GetFoodItemUseCase(this.repository);

  Future<Either<Failure, FoodEntity>> call(String itemId) async {
    return await repository.getFoodItem(itemId);
  }
}

