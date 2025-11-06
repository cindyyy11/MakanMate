import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_datasource.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RestaurantEntity>> getCategories() async {
    return await remoteDataSource.fetchCategories();
  }

  @override
  Future<List<RestaurantEntity>> getRecommendations() async {
    return await remoteDataSource.fetchRecommendations();
  }
}
