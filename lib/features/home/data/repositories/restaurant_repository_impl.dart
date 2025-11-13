import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/home/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remote;

  RestaurantRepositoryImpl(this.remote);

  @override
  Future<List<RestaurantEntity>> getRestaurants() {
    return remote.getRestaurants();
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String id) {
    return remote.getRestaurantById(id);
  }
}
