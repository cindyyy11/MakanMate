import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makan_mate/core/widgets/bottom_nav_widget.dart';
import 'package:makan_mate/features/favorite/presentation/pages/favorite_page.dart';
import 'package:makan_mate/screens/home_screen.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({Key? key}) : super(key: key);

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  final StreamController<int> _selected = StreamController<int>();
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoading = true;
  int _currentIndex = 2; 
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied.')),
      );
      return;
    }

    // Get user current location
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userPosition = position;
    });

    // Once we get location, load nearby restaurants
    _loadNearbyRestaurants(position);
  }

  Future<void> _loadNearbyRestaurants(Position position) async {
    final snapshot = await FirebaseFirestore.instance.collection('restaurants').get();

    const maxDistanceKm = 5.0; 

    final nearby = snapshot.docs.where((doc) {
      final data = doc.data();
      final lat = data['latitude'];
      final lon = data['longitude'];
      if (lat == null || lon == null) return false;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lon,
      );
      return distance / 1000 <= maxDistanceKm;
    }).map((e) => e.data()).toList();

    setState(() {
      _restaurants = nearby;
      _isLoading = false;
    });
  }

  void _spinWheel() {
    if (_restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No nearby restaurants found.')),
      );
      return;
    }

    final randomIndex = Random().nextInt(_restaurants.length);
    _selected.add(randomIndex);

    Future.delayed(const Duration(seconds: 4), () {
      final restaurant = _restaurants[randomIndex];
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(restaurant['name'] ?? 'Unknown'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                restaurant['image'] ?? '',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60),
              ),
              const SizedBox(height: 12),
              Text(restaurant['cuisine'] ?? '-'),
              const SizedBox(height: 4),
              Text(restaurant['priceRange'] ?? '-'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(restaurant['rating']?.toString() ?? '-'),
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
          : _restaurants.isEmpty
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
                            for (final r in _restaurants)
                              FortuneItem(
                                child: Text(
                                  r['name'] ?? 'Unknown',
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
                        label: const Text('SPIN NOW',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavWidget(
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
      ),
    );
  }

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }
}
