import '../entities/map_location_entity.dart';
import '../repositories/map_repository.dart';

class GetNearbyRestaurantsUseCase {
  final MapRepository repository;

  GetNearbyRestaurantsUseCase(this.repository);

  Future<List<MapLocationEntity>> call(double lat, double lng) async {
    return await repository.getNearbyRestaurants(lat, lng);
  }
}
