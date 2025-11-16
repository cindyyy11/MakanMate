import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_food_entity.dart';

class SearchFoodModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String name;
  final String? imageUrl;
  final double price;
  final String? description;
  final String? category;
  final int? calories;
  final bool available;

  SearchFoodModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.name,
    this.imageUrl,
    required this.price,
    this.description,
    this.category,
    this.calories,
    required this.available,
  });

  factory SearchFoodModel.fromDoc(
    QueryDocumentSnapshot doc,
    String vendorId,
    String vendorName,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchFoodModel(
      id: doc.id,
      vendorId: vendorId,
      vendorName: vendorName,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0).toDouble(),
      description: data['description'],
      category: data['category'],
      calories: data['calories'],
      available: data['available'] ?? true,
    );
  }

  SearchResultFoodEntity toEntity() {
    return SearchResultFoodEntity(
      id: id,
      vendorId: vendorId,
      vendorName: vendorName,
      name: name,
      imageUrl: imageUrl,
      price: price,
      description: description,
      category: category,
      calories: calories,
      available: available,
    );
  }
}
