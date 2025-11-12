import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/food/domain/entities/food_entity.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';

/// Use case for getting popular food items
class GetPopularFoodItemsUseCase {
  final FoodRepository repository;

  GetPopularFoodItemsUseCase(this.repository);

  Future<Either<Failure, List<FoodEntity>>> call(
    GetPopularFoodItemsParams params,
  ) async {
    return await repository.getPopularItems(limit: params.limit);
  }
}

/// Parameters for getting popular food items
class GetPopularFoodItemsParams extends Equatable {
  final int limit;

  const GetPopularFoodItemsParams({this.limit = 50});

  @override
  List<Object> get props => [limit];
}

