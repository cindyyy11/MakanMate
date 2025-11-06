import 'package:makan_mate/features/map/data/datasources/map_remote_datasource.dart';

import '../../domain/entities/map_location_entity.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MapLocationEntity>> getNearbyRestaurants(double lat, double lng) async {
    return await remoteDataSource.fetchNearbyRestaurants(lat, lng);
  }
}
