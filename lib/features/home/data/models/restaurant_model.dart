import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.rating,
    required super.address,
    required super.cuisineType,
    required super.priceRange,
    required super.isHalal,
    required super.isVegetarian,
    required super.latitude,
    required super.longitude,
    required super.openingHours,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print(
      "TYPES OF RATING LAT AND LONG ${data['rating'].runtimeType}${data['latitude'].runtimeType}${data['longitude'].runtimeType}",
    );
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      cuisineType: data['cuisineType'] ?? data['cuisine'] ?? '',
      priceRange: data['priceRange'] ?? '',
      isHalal: data['isHalal'] ?? false,
      isVegetarian: data['isVegetarian'] ?? false,
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      openingHours: data['openingHours'] ?? ['9am', '5pm'],
    );
  }
}
