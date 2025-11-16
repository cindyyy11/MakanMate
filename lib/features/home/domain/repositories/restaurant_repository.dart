import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantEntity>> getRestaurants();
  Future<RestaurantEntity> getRestaurantById(String id);
}
