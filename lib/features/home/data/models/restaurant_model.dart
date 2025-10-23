import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required double rating,
    required String address,
    required String cuisineType,
    required String priceRange,
    required bool isHalal,
    required bool isVegetarian,
    required double latitude,
    required double longitude,
    required List<String> openingHours,
  }) : super(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    rating: rating,
    address: address,
    cuisineType: cuisineType,
    priceRange: priceRange,
    isHalal: isHalal,
    isVegetarian: isVegetarian,
    latitude: latitude,
    longitude: longitude,
    openingHours: openingHours,
  );
  
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as GeoPoint;
    
    return RestaurantModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] as String? ?? '',
      cuisineType: data['cuisineType'] as String? ?? '',
      priceRange: data['priceRange'] as String? ?? '\$\$',
      isHalal: data['isHalal'] as bool? ?? false,
      isVegetarian: data['isVegetarian'] as bool? ?? false,
      latitude: location.latitude,
      longitude: location.longitude,
      openingHours: List<String>.from(data['openingHours'] as List? ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'address': address,
      'cuisineType': cuisineType,
      'priceRange': priceRange,
      'isHalal': isHalal,
      'isVegetarian': isVegetarian,
      'location': GeoPoint(latitude, longitude),
      'openingHours': openingHours,
    };
  }
}