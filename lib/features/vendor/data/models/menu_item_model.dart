import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.price,
    required super.imageUrl,
    required super.available,
    required super.calories,
  });

  MenuItemModel copyWith({
      String? id,
      String? name,
      String? description,
      String? category,
      double? price,
      String? imageUrl,
      bool? available,
      int? calories,
    }) {
      return MenuItemModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        available: available ?? this.available,
        calories: calories ?? this.calories,
      );
    }

  factory MenuItemModel.fromMap(Map<String, dynamic> map) => MenuItemModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        category: map['category'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        imageUrl: map['imageUrl'] ?? '',
        available: map['available'] ?? true,
        calories: map['calories'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'imageUrl': imageUrl,
        'available': available,
        'calories': calories,
      };
}