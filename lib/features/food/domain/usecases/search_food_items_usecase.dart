import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/food/domain/entities/food_entity.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';

/// Use case for searching food items
class SearchFoodItemsUseCase {
  final FoodRepository repository;

  SearchFoodItemsUseCase(this.repository);

  Future<Either<Failure, List<FoodEntity>>> call(String query) async {
    return await repository.searchFoodItems(query);
  }
}

