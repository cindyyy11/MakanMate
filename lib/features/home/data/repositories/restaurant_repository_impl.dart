import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/home/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RestaurantEntity>> getCategories() async {
    return await remoteDataSource.fetchCategories();
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
    return await remoteDataSource.getRestaurantById(id);
  }

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    return await remoteDataSource.getRestaurants();
  }

  @override
  Future<List<RestaurantEntity>> getRecommendations() async {
    return await remoteDataSource.fetchRecommendations();
  }
}
