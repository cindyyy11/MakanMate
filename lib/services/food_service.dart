import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makan_mate/models/food_models.dart';
import 'package:makan_mate/models/review_models.dart';
import 'package:makan_mate/models/user_models.dart';
import 'package:makan_mate/services/base_service.dart';
import 'package:makan_mate/services/user_service.dart';


class FoodService extends BaseService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;
  FoodService._internal();

  static const String FOOD_COLLECTION = 'food_items';
  static const String RESTAURANT_COLLECTION = 'restaurants';
  static const String REVIEWS_COLLECTION = 'reviews';

  // Get food item by ID
  Future<FoodItem?> getFoodItem(String itemId) async {
    try {
      final doc = await BaseService.firestore.collection(FOOD_COLLECTION).doc(itemId).get();
      
      if (doc.exists) {
        return FoodItem.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      BaseService.logger.e('Error getting food item: $e');
      return null;
    }
  }

  // Get all food items (for AI training)
  Future<List<FoodItem>> getAllFoodItems({int limit = 10000}) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting all food items: $e');
      return [];
    }
  }

  // Get food items by restaurant
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting food items by restaurant: $e');
      return [];
    }
  }

  // Get food items by categories
  Future<List<FoodItem>> getFoodItemsByCategories(List<String> categories) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('categories', arrayContainsAny: categories)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting food items by categories: $e');
      return [];
    }
  }

  // Get food items by cuisine type
  Future<List<FoodItem>> getFoodItemsByCuisine(String cuisineType) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('cuisineType', isEqualTo: cuisineType)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting food items by cuisine: $e');
      return [];
    }
  }

  // Get popular food items
  Future<List<FoodItem>> getPopularItems({int limit = 50}) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .orderBy('totalOrders', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting popular items: $e');
      return [];
    }
  }

  // Get highly rated items
  Future<List<FoodItem>> getHighlyRatedItems({int limit = 50}) async {
    try {
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('averageRating', isGreaterThan: 4.0)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting highly rated items: $e');
      return [];
    }
  }

  // Get nearby food items
  Future<List<FoodItem>> getNearbyFoodItems(
    Location userLocation, {
    double radiusKm = 10.0,
    int limit = 100,
  }) async {
    try {
      // Get all food items (in a real app, you'd use geohash for better performance)
      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .limit(limit * 2) // Get more to filter by distance
          .get();

      List<FoodItem> allItems = query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
      
      // Filter by distance
      List<FoodItem> nearbyItems = [];
      
      for (FoodItem item in allItems) {
        double distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          item.restaurantLocation.latitude,
          item.restaurantLocation.longitude,
        ) / 1000; // Convert to km
        
        if (distance <= radiusKm) {
          nearbyItems.add(item);
        }
        
        if (nearbyItems.length >= limit) break;
      }

      return nearbyItems;
    } catch (e) {
      BaseService.logger.e('Error getting nearby food items: $e');
      return [];
    }
  }

  // Get contextual food items (based on time, weather, etc.)
  Future<List<FoodItem>> getContextualItems(
    Map<String, dynamic> context,
    UserModel user,
  ) async {
    try {
      List<String> contextualCategories = _getContextualCategories(context);
      
      if (contextualCategories.isEmpty) {
        return await getPopularItems();
      }

      final query = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('categories', arrayContainsAny: contextualCategories)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting contextual items: $e');
      return [];
    }
  }

  // Search food items
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      final searchQuery = query.toLowerCase();
      
      // Search by name
      final nameQuery = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: searchQuery + 'z')
          .limit(50)
          .get();

      // Search by categories
      final categoryQuery = await BaseService.firestore
          .collection(FOOD_COLLECTION)
          .where('categories', arrayContains: searchQuery)
          .limit(50)
          .get();

      Set<String> seenIds = {};
      List<FoodItem> results = [];
      
      // Combine results without duplicates
      for (var doc in [...nameQuery.docs, ...categoryQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(FoodItem.fromFirestore(doc));
        }
      }

      return results;
    } catch (e) {
      BaseService.logger.e('Error searching food items: $e');
      return [];
    }
  }

  // Get candidate items for recommendations
  Future<List<FoodItem>> getCandidateItems(String userId) async {
    try {
      UserModel? user = await UserService().getUser(userId);
      if (user == null) return await getPopularItems();

      // Get nearby items
      List<FoodItem> nearbyItems = await getNearbyFoodItems(user.currentLocation);
      
      // Get items matching user preferences
      List<String> preferredCuisines = user.cuisinePreferences.entries
          .where((entry) => entry.value > 0.6)
          .map((entry) => entry.key)
          .toList();

      List<FoodItem> preferredItems = [];
      for (String cuisine in preferredCuisines) {
        final items = await getFoodItemsByCuisine(cuisine);
        preferredItems.addAll(items);
      }

      // Combine and deduplicate
      Set<String> seenIds = {};
      List<FoodItem> candidates = [];
      
      for (var item in [...nearbyItems, ...preferredItems]) {
        if (!seenIds.contains(item.id)) {
          seenIds.add(item.id);
          candidates.add(item);
        }
      }

      return candidates.take(200).toList();
    } catch (e) {
      BaseService.logger.e('Error getting candidate items: $e');
      return await getPopularItems();
    }
  }

  // Add review
  Future<void> addReview(Review review) async {
    try {
      await BaseService.firestore.collection(REVIEWS_COLLECTION).add(review.toJson());
      
      // Update food item ratings
      await _updateItemRatings(review.itemId);
      
      BaseService.logger.i('Review added: ${review.itemId}');
    } catch (e) {
      BaseService.logger.e('Error adding review: $e');
      rethrow;
    }
  }

  // Get reviews for item
  Future<List<Review>> getItemReviews(String itemId) async {
    try {
      final query = await BaseService.firestore
          .collection(REVIEWS_COLLECTION)
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting item reviews: $e');
      return [];
    }
  }

  // Helper methods
  List<String> _getContextualCategories(Map<String, dynamic> context) {
    List<String> categories = [];
    
    int hour = context['hour'] ?? DateTime.now().hour;
    String weather = context['weather'] ?? 'clear';
    
    // Time-based categories
    if (hour >= 6 && hour <= 10) {
      categories.addAll(['breakfast', 'coffee', 'pastry']);
    } else if (hour >= 12 && hour <= 14) {
      categories.addAll(['lunch', 'rice', 'noodles']);
    } else if (hour >= 18 && hour <= 21) {
      categories.addAll(['dinner', 'main_course']);
    } else if (hour >= 21 || hour <= 2) {
      categories.addAll(['supper', 'light_meal']);
    }
    
    // Weather-based categories
    switch (weather.toLowerCase()) {
      case 'rainy':
        categories.addAll(['hot', 'soup', 'warm']);
        break;
      case 'hot':
      case 'sunny':
        categories.addAll(['cold', 'refreshing', 'ice_cream']);
        break;
    }
    
    return categories;
  }

  Future<void> _updateItemRatings(String itemId) async {
    try {
      final reviews = await getItemReviews(itemId);
      
      if (reviews.isNotEmpty) {
        double totalRating = reviews.map((r) => r.rating).reduce((a, b) => a + b);
        double averageRating = totalRating / reviews.length;
        
        await BaseService.firestore.collection(FOOD_COLLECTION).doc(itemId).update({
          'averageRating': averageRating,
          'totalRatings': reviews.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      BaseService.logger.e('Error updating item ratings: $e');
    }
  }
}