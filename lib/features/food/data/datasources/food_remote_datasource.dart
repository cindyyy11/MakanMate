import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';

/// Remote data source interface for food items
abstract class FoodRemoteDataSource {
  Future<FoodItem> getFoodItem(String itemId);
  Future<List<FoodItem>> getAllFoodItems({int limit = 10000});
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId);
  Future<List<FoodItem>> getFoodItemsByCategories(List<String> categories);
  Future<List<FoodItem>> getFoodItemsByCuisine(String cuisineType);
  Future<List<FoodItem>> getPopularItems({int limit = 50});
  Future<List<FoodItem>> getHighlyRatedItems({int limit = 50});
  Future<List<FoodItem>> getNearbyFoodItems(
    Location userLocation, {
    double radiusKm = 10.0,
    int limit = 100,
  });
  Future<List<FoodItem>> getContextualItems(
    Map<String, dynamic> context,
    Location userLocation,
  );
  Future<List<FoodItem>> searchFoodItems(String query);
  Future<List<FoodItem>> getCandidateItems(String userId);
}

/// Implementation of FoodRemoteDataSource
class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String FOOD_COLLECTION = 'food_items';

  FoodRemoteDataSourceImpl({required this.firestore});

  @override
  Future<FoodItem> getFoodItem(String itemId) async {
    try {
      final doc = await firestore.collection(FOOD_COLLECTION).doc(itemId).get();

      if (!doc.exists) {
        throw ServerException('Food item not found: $itemId');
      }

      return FoodItem.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get food item: $e');
    }
  }

  @override
  Future<List<FoodItem>> getAllFoodItems({int limit = 10000}) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get all food items: $e');
    }
  }

  @override
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get food items by restaurant: $e');
    }
  }

  @override
  Future<List<FoodItem>> getFoodItemsByCategories(
    List<String> categories,
  ) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .where('categories', arrayContainsAny: categories)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get food items by categories: $e');
    }
  }

  @override
  Future<List<FoodItem>> getFoodItemsByCuisine(String cuisineType) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .where('cuisineType', isEqualTo: cuisineType)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get food items by cuisine: $e');
    }
  }

  @override
  Future<List<FoodItem>> getPopularItems({int limit = 50}) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .orderBy('totalOrders', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get popular items: $e');
    }
  }

  @override
  Future<List<FoodItem>> getHighlyRatedItems({int limit = 50}) async {
    try {
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .where('averageRating', isGreaterThan: 4.0)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get highly rated items: $e');
    }
  }

  @override
  Future<List<FoodItem>> getNearbyFoodItems(
    Location userLocation, {
    double radiusKm = 10.0,
    int limit = 100,
  }) async {
    try {
      // Get all food items (in a real app, you'd use geohash for better performance)
      final query = await firestore
          .collection(FOOD_COLLECTION)
          .limit(limit * 2) // Get more to filter by distance
          .get();

      List<FoodItem> allItems = query.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();

      // Filter by distance
      List<FoodItem> nearbyItems = [];

      for (FoodItem item in allItems) {
        double distance =
            Geolocator.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              item.restaurantLocation.latitude,
              item.restaurantLocation.longitude,
            ) /
            1000; // Convert to km

        if (distance <= radiusKm) {
          nearbyItems.add(item);
        }

        if (nearbyItems.length >= limit) break;
      }

      return nearbyItems;
    } catch (e) {
      throw ServerException('Failed to get nearby food items: $e');
    }
  }

  @override
  Future<List<FoodItem>> getContextualItems(
    Map<String, dynamic> context,
    Location userLocation,
  ) async {
    try {
      List<String> contextualCategories = _getContextualCategories(context);

      if (contextualCategories.isEmpty) {
        return await getPopularItems();
      }

      final query = await firestore
          .collection(FOOD_COLLECTION)
          .where('categories', arrayContainsAny: contextualCategories)
          .limit(100)
          .get();

      return query.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get contextual items: $e');
    }
  }

  @override
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      final searchQuery = query.toLowerCase();

      // Search by name
      final nameQuery = await firestore
          .collection(FOOD_COLLECTION)
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: '${searchQuery}z')
          .limit(50)
          .get();

      // Search by categories
      final categoryQuery = await firestore
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
      throw ServerException('Failed to search food items: $e');
    }
  }

  @override
  Future<List<FoodItem>> getCandidateItems(String userId) async {
    try {
      // Get user document to get preferences and location
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return await getPopularItems();
      }

      final userData = userDoc.data()!;
      final userLocation = Location.fromJson(userData['currentLocation'] ?? {});

      // Get nearby items
      List<FoodItem> nearbyItems = await getNearbyFoodItems(userLocation);

      // Get items matching user preferences
      final cuisinePreferences = Map<String, double>.from(
        userData['cuisinePreferences'] ?? {},
      );
      List<String> preferredCuisines = cuisinePreferences.entries
          .where((entry) => entry.value > 0.6)
          .map((entry) => entry.key)
          .toList();

      List<FoodItem> preferredItems = [];
      for (String cuisine in preferredCuisines) {
        final items = await getFoodItemsByCuisine(cuisine);
        preferredItems.addAll(items);
      }

      // Combine and remove duplicates
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
      throw ServerException('Failed to get candidate items: $e');
    }
  }

  /// Get contextual categories based on context (time, weather, etc.)
  List<String> _getContextualCategories(Map<String, dynamic> context) {
    List<String> categories = [];

    // Time-based categories
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      categories.add('breakfast');
    } else if (hour >= 11 && hour < 15) {
      categories.add('lunch');
    } else if (hour >= 15 && hour < 18) {
      categories.add('snacks');
    } else {
      categories.add('dinner');
    }

    // Weather-based categories (if provided)
    if (context['weather'] != null) {
      final weather = context['weather'] as String;
      if (weather.toLowerCase().contains('rain') ||
          weather.toLowerCase().contains('cold')) {
        categories.add('soup');
        categories.add('hot');
      }
    }

    return categories;
  }
}
