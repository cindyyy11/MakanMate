class MenuItemEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool available;
  final int calories;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.calories,
  });

  MenuItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? calories,
    String? imageUrl,
    bool? available,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
    );
  }
}
