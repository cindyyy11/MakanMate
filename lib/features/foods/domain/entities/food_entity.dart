// lib/features/foods/domain/entities/food_entity.dart
class FoodEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool available;
  final String? category;
  final int? calories;

  const FoodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.available,
    this.category,
    this.calories,
  });

  factory FoodEntity.fromMap(String id, Map<String, dynamic> data) {
    return FoodEntity(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      available: data['available'] ?? true,
      category: data['category'],
      calories: data['calories'],
    );
  }
}
