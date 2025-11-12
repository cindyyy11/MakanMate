import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';

/// Food item entity (Domain layer)
/// Pure Dart class representing a food item
class FoodEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String restaurantId;
  final List<String> imageUrls;
  final List<String> categories;
  final String cuisineType;
  final double price;
  final double spiceLevel;
  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final Map<String, double> nutritionalInfo;
  final List<String> ingredients;
  final Location restaurantLocation;
  final double averageRating;
  final int totalRatings;
  final int totalOrders;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.restaurantId,
    this.imageUrls = const [],
    this.categories = const [],
    required this.cuisineType,
    required this.price,
    this.spiceLevel = 0.5,
    this.isHalal = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.nutritionalInfo = const {},
    this.ingredients = const [],
    required this.restaurantLocation,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.totalOrders = 0,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    restaurantId,
    imageUrls,
    categories,
    cuisineType,
    price,
    spiceLevel,
    isHalal,
    isVegetarian,
    isVegan,
    isGlutenFree,
    nutritionalInfo,
    ingredients,
    restaurantLocation,
    averageRating,
    totalRatings,
    totalOrders,
    metadata,
    createdAt,
    updatedAt,
  ];

  FoodEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? restaurantId,
    List<String>? imageUrls,
    List<String>? categories,
    String? cuisineType,
    double? price,
    double? spiceLevel,
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    Map<String, double>? nutritionalInfo,
    List<String>? ingredients,
    Location? restaurantLocation,
    double? averageRating,
    int? totalRatings,
    int? totalOrders,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      restaurantId: restaurantId ?? this.restaurantId,
      imageUrls: imageUrls ?? this.imageUrls,
      categories: categories ?? this.categories,
      cuisineType: cuisineType ?? this.cuisineType,
      price: price ?? this.price,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      isHalal: isHalal ?? this.isHalal,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      ingredients: ingredients ?? this.ingredients,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalOrders: totalOrders ?? this.totalOrders,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
