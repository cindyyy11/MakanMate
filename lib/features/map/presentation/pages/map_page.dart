import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapLoaded) {
            if (state.locations.isEmpty) {
              return const Center(
                child: Text(
                  'No nearby restaurants found within 5 km.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            final markers = state.locations.map((loc) {
              return Marker(
                markerId: MarkerId(loc.id),
                position: LatLng(loc.latitude, loc.longitude),
                infoWindow: InfoWindow(title: loc.name, snippet: loc.address),
              );
            }).toSet();

            final first = state.locations.first;

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(first.latitude, first.longitude),
                zoom: 13,
              ),
              markers: markers,
              myLocationEnabled: true,
              onMapCreated: (controller) => _controller = controller,
            );
          }

          if (state is MapError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
