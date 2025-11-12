import 'package:geolocator/geolocator.dart';
import 'package:makan_mate/features/map/domain/entities/map_location_entity.dart';

abstract class MapState {}

class MapInitial extends MapState {}
class MapLoading extends MapState {}
class MapLoaded extends MapState {
  final Position userPosition;
  final List<MapLocationEntity> locations;
  MapLoaded(this.userPosition, this.locations);
}
class MapError extends MapState {
  final String message;
  MapError(this.message);
}
