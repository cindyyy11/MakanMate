import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:geolocator/geolocator.dart';

import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({Key? key}) : super(key: key);

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  final StreamController<int> _selected = StreamController<int>();
  List<RestaurantEntity> _nearbyRestaurants = [];
  bool _isLoading = true;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeBloc>().state;

      if (state is HomeLoaded) {
        _getUserLocation();
      } else {
        context.read<HomeBloc>().stream.listen((s) {
          if (s is HomeLoaded) {
            _getUserLocation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  // GET USER LOCATION
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable location services.")),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _userPosition = position);

    _filterNearbyRestaurants();
  }

  void _filterNearbyRestaurants() {
    final state = context.read<HomeBloc>().state;

    if (state is! HomeLoaded) {
      setState(() => _isLoading = false);
      return;
    }

    final allRestaurants = state.recommendations;
    const maxDistanceKm = 5.0;

    final filtered = allRestaurants.where((r) {
      if (_userPosition == null) return false;

      final vendor = r.vendor;

      if (vendor.latitude == null || vendor.longitude == null) {
        return false; // skip restaurants with no coordinates
      }

      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        vendor.latitude!,
        vendor.longitude!,
      );

      return distance / 1000 <= maxDistanceKm;
    }).toList();

    setState(() {
      _nearbyRestaurants = filtered;
      _isLoading = false;
    });
  }

  void _spinWheel() {
    if (_nearbyRestaurants.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("At least 2 nearby restaurants are required to spin."),
        ),
      );
      return;
    }

    final randomIndex = Random().nextInt(_nearbyRestaurants.length);
    _selected.add(randomIndex);

    Future.delayed(const Duration(seconds: 4), () {
      final r = _nearbyRestaurants[randomIndex];
      final vendor = r.vendor;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(vendor.businessName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                vendor.businessLogoUrl ?? "",
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 60),
              ),
              const SizedBox(height: 12),
              Text("Cuisine: ${vendor.cuisineType ?? '-'}"),
              Text("Price Range: ${vendor.priceRange ?? '-'}"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(vendor.ratingAverage?.toStringAsFixed(1) ?? "-"),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Spin the Wheel"),
      backgroundColor: Colors.orange[300],
    ),
    body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _nearbyRestaurants.isEmpty
        ? const Center(child: Text("No nearby restaurants found."))
        : _nearbyRestaurants.length < 2
            ? const Center(child: Text("Need at least 2 nearby restaurants to spin."))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// WHEEL
                    Expanded(
                      child: FortuneWheel(
                        selected: _selected.stream,
                        indicators: const <FortuneIndicator>[
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(color: Colors.orange),
                          ),
                        ],
                        items: _nearbyRestaurants
                            .map(
                              (r) => FortuneItem(
                                child: Text(r.vendor.businessName),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _spinWheel,
              icon: const Icon(Icons.casino, color: Colors.white),
              label: const Text(
                "SPIN NOW",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
