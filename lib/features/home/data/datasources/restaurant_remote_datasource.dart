import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/home/data/models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  });
  
  Future<RestaurantModel> getRestaurantById(String id);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;
  
  RestaurantRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<List<RestaurantModel>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    try {
      Query query = firestore.collection('restaurants');
      
      // Apply filters
      if (cuisineType != null) {
        query = query.where('cuisineType', isEqualTo: cuisineType);
      }
      
      if (isHalal != null) {
        query = query.where('isHalal', isEqualTo: isHalal);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch restaurants: ${e.toString()}');
    }
  }
  
  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final doc = await firestore.collection('restaurants').doc(id).get();
      
      if (!doc.exists) {
        throw ServerException('Restaurant not found');
      }
      
      return RestaurantModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to fetch restaurant: ${e.toString()}');
    }
  }
}