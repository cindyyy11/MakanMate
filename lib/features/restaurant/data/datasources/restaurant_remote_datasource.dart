import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/restaurant/data/models/restaurant_models.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<Restaurant>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  });
  
  Future<Restaurant> getRestaurantById(String id);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;
  
  RestaurantRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<List<Restaurant>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    try {
      Query query = firestore.collection('restaurants');
      
      // Apply filters
      if (cuisineType != null) {
        query = query.where('cuisineTypes', arrayContains: cuisineType);
      }
      
      if (isHalal != null) {
        query = query.where('isHalalCertified', isEqualTo: isHalal);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => Restaurant.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch restaurants: ${e.toString()}');
    }
  }
  
  @override
  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final doc = await firestore.collection('restaurants').doc(id).get();
      
      if (!doc.exists) {
        throw ServerException('Restaurant not found');
      }
      
      return Restaurant.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to fetch restaurant: ${e.toString()}');
    }
  }
}