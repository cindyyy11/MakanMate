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
    _getUserLocation();
  }

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied. Cannot load nearby restaurants.',
            ),
          ),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userPosition = position;
    });

    _filterNearbyRestaurants();
  }

  void _filterNearbyRestaurants() {
    final homeState = context.read<HomeBloc>().state;

    if (homeState is! HomeLoaded) {
      // HomeBloc not ready
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final allRestaurants = homeState.recommendations;

    const maxDistanceKm = 5.0;

    final filtered = allRestaurants.where((r) {
      if (_userPosition == null) return false;

      final outlets = r.vendor.outlets;
      if (outlets.isEmpty) return false;

      // use first outlet as main location
      final o = outlets.first;

      if (o.latitude == null || o.longitude == null) return false;

      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        o.latitude!,
        o.longitude!,
      );

      return distance / 1000 <= maxDistanceKm;
    }).toList();

    setState(() {
      _nearbyRestaurants = filtered;
      _isLoading = false;
    });
  }

  void _spinWheel() {
    if (_nearbyRestaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No nearby restaurants found.')),
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
                vendor.businessLogoUrl ?? '',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 60),
              ),
              const SizedBox(height: 12),
              Text("Cuisine: ${vendor.cuisine ?? '-'}"),
              Text("Price Range: ${vendor.priceRange ?? '-'}"),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(vendor.ratingAverage?.toStringAsFixed(1) ?? '-'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
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
        title: const Text('Spin the Wheel'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nearbyRestaurants.isEmpty
          ? const Center(child: Text('No nearby restaurants found.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: FortuneWheel(
                      selected: _selected.stream,
                      indicators: const <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: TriangleIndicator(color: Colors.orange),
                        ),
                      ],
                      items: [
                        for (final r in _nearbyRestaurants)
                          FortuneItem(
                            child: Text(
                              r.vendor.businessName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: const FortuneItemStyle(
                              color: Colors.orangeAccent,
                              borderColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(180, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _spinWheel,
                    icon: const Icon(Icons.casino, color: Colors.white),
                    label: const Text(
                      'SPIN NOW',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
      /* bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
              break;
            case 2:
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
              break;
          }
        },
      ), */
    );
  }
}
