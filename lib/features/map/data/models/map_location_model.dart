import '../../domain/entities/map_location_entity.dart';

class MapLocationModel extends MapLocationEntity {
  MapLocationModel({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) : super(
          id: id,
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
