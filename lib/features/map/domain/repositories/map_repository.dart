import '../entities/map_location_entity.dart';

abstract class MapRepository {
  Future<List<MapLocationEntity>> getNearbyRestaurants(double lat, double lng);
}
