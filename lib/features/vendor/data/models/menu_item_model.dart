import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vendor_profile_entity.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool available;
  final int calories;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.calories,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      available: data['available'] ?? true,
      calories: data['calories'] ?? 0,
    );
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      description: description,
      category: category,
      price: price,
      imageUrl: imageUrl,
      available: available,
      calories: calories,
    );
  }
}
