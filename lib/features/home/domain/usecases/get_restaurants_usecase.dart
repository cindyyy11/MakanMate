import 'package:dartz/dartz.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class GetRestaurantsUseCase {
  final RestaurantRepository repository;

  GetRestaurantsUseCase(this.repository);

  Future<Future<List<RestaurantEntity>>> call({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    return repository.getRestaurants();
  }
}
