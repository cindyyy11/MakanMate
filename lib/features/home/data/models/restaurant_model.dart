import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  RestaurantModel({
    required super.id,
    required super.name,
    required super.cuisine,
    required super.halal,
    required super.rating,
    required super.priceRange,
    required super.image,
    required super.location,
    required super.description,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      cuisine: data['cuisine'] ?? '',
      halal: data['halal'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      priceRange: data['priceRange'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
