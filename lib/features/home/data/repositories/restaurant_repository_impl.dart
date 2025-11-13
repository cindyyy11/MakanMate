import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_datasource.dart';

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
