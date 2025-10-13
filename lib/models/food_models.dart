import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/models/base_model.dart';
import 'package:makan_mate/models/user_models.dart';


part 'food_models.g.dart';

@JsonSerializable()
class FoodItem extends BaseModel {
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
  
  const FoodItem({
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

  factory FoodItem.fromJson(Map<String, dynamic> json) => _$FoodItemFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
  
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FoodItem.fromJson({
      'id': doc.id,
      ...data,
    });
  }
  
  // Convert to feature vector for AI
  List<double> toFeatureVector() {
    List<double> features = [];
    
    // Basic features
    features.add(price / 100.0); 
    features.add(spiceLevel);
    features.add(isHalal ? 1.0 : 0.0);
    features.add(isVegetarian ? 1.0 : 0.0);
    features.add(isVegan ? 1.0 : 0.0);
    features.add(isGlutenFree ? 1.0 : 0.0);
    
    // Cuisine type one-hot encoding
    List<String> cuisines = ['malay', 'chinese', 'indian', 'western', 'thai'];
    for (String cuisine in cuisines) {
      features.add(cuisineType.toLowerCase() == cuisine ? 1.0 : 0.0);
    }
    
    // Category features
    List<String> commonCategories = ['rice', 'noodles', 'soup', 'grilled', 'fried', 'dessert', 'beverage'];
    for (String category in commonCategories) {
      bool hasCategory = categories.any((c) => c.toLowerCase().contains(category));
      features.add(hasCategory ? 1.0 : 0.0);
    }
    
    // Nutritional features
    features.add((nutritionalInfo['calories'] ?? 0) / 1000.0);
    features.add((nutritionalInfo['protein'] ?? 0) / 100.0);
    features.add((nutritionalInfo['carbs'] ?? 0) / 100.0);
    features.add((nutritionalInfo['fat'] ?? 0) / 100.0);
    
    // Popularity features
    features.add(averageRating / 5.0);
    features.add((totalRatings > 0 ? (totalRatings / 100.0).clamp(0.0, 1.0) : 0.0));
    features.add((totalOrders > 0 ? (totalOrders / 100.0).clamp(0.0, 1.0) : 0.0));
    
    return features;
  }
  
  @override
  List<Object?> get props => [
    id, name, description, restaurantId, imageUrls, categories,
    cuisineType, price, spiceLevel, isHalal, isVegetarian, isVegan,
    isGlutenFree, nutritionalInfo, ingredients, restaurantLocation,
    averageRating, totalRatings, totalOrders, metadata, createdAt, updatedAt,
  ];
}