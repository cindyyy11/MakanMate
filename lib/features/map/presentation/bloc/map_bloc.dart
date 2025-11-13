import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makan_mate/features/map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyRestaurantsUseCase getNearbyRestaurants;

  MapBloc(this.getNearbyRestaurants) : super(MapInitial()) {
    on<LoadMapEvent>(_onLoadMapEvent);
  }

  Future<void> _onLoadMapEvent(
    LoadMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(MapError('Location services are disabled.'));
        return;
      }

      // Request permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(MapError('Location permission denied.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(MapError('Location permission permanently denied.'));
        return;
      }

      // ✅ Get actual position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 Current location: ${position.latitude}, ${position.longitude}');

      // ✅ Pass the correct coordinates
      final locations = await getNearbyRestaurants(
        position.latitude,
        position.longitude,
      );

      emit(MapLoaded(position, locations));
    } catch (e) {
      emit(MapError('Failed to load map data: $e'));
    }
  }
}
