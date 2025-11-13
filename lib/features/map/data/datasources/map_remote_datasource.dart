import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/map_location_model.dart';

abstract class MapRemoteDataSource {
  Future<List<MapLocationModel>> fetchNearbyRestaurants(double lat, double lng);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  static const String _apiKey = 'AIzaSyDYl4dAzQk39ncEasG0OQ8Ee6H2t0C5VXI'; 

  @override
  Future<List<MapLocationModel>> fetchNearbyRestaurants(double lat, double lng) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');

    final body = jsonEncode({
      "includedTypes": ["restaurant"],
      "maxResultCount": 20,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": lat, "longitude": lng},
          "radius": 5000.0 // 5 km radius
        }
      }
    });

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location',
    };

    print('🌍 Sending Places API v1 request...');
    final response = await http.post(url, headers: headers, body: body);
    print('📦 Status Code: ${response.statusCode}');
    print('📦 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['places'] == null) {
        print('⚠️ No "places" field in response.');
        return [];
      }

      final results = data['places'] as List;
      print('✅ Found ${results.length} restaurants');

      return results.map((place) {
        final loc = place['location'];
        return MapLocationModel(
          id: place['id'] ?? '',
          name: place['displayName']?['text'] ?? 'Unknown',
          address: place['formattedAddress'] ?? 'No address',
          latitude: loc?['latitude']?.toDouble() ?? 0.0,
          longitude: loc?['longitude']?.toDouble() ?? 0.0,
        );
      }).toList();
    } else {
      throw Exception('Failed Places API request: ${response.statusCode}');
    }
  }
}
