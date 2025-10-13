// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  restaurantId: json['restaurantId'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  cuisineType: json['cuisineType'] as String,
  price: (json['price'] as num).toDouble(),
  spiceLevel: (json['spiceLevel'] as num?)?.toDouble() ?? 0.5,
  isHalal: json['isHalal'] as bool? ?? false,
  isVegetarian: json['isVegetarian'] as bool? ?? false,
  isVegan: json['isVegan'] as bool? ?? false,
  isGlutenFree: json['isGlutenFree'] as bool? ?? false,
  nutritionalInfo:
      (json['nutritionalInfo'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  restaurantLocation: Location.fromJson(
    json['restaurantLocation'] as Map<String, dynamic>,
  ),
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
  totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'restaurantId': instance.restaurantId,
  'imageUrls': instance.imageUrls,
  'categories': instance.categories,
  'cuisineType': instance.cuisineType,
  'price': instance.price,
  'spiceLevel': instance.spiceLevel,
  'isHalal': instance.isHalal,
  'isVegetarian': instance.isVegetarian,
  'isVegan': instance.isVegan,
  'isGlutenFree': instance.isGlutenFree,
  'nutritionalInfo': instance.nutritionalInfo,
  'ingredients': instance.ingredients,
  'restaurantLocation': instance.restaurantLocation,
  'averageRating': instance.averageRating,
  'totalRatings': instance.totalRatings,
  'totalOrders': instance.totalOrders,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
