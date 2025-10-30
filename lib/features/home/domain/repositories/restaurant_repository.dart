import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  });
  
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id);
}