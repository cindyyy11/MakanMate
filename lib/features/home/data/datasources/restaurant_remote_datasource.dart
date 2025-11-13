import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/home/data/models/restaurant_model.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSource(this.firestore);

  // ✅ Fetch by category (grouped by cuisine)
  Future<List<RestaurantModel>> fetchCategories() async {
    final snapshot = await firestore.collection('restaurants').get();
    final all = snapshot.docs
        .map((doc) => RestaurantModel.fromFirestore(doc))
        .toList();

    // Optional: return one per cuisine
    final seen = <String>{};
    final uniqueByCuisine = <RestaurantModel>[];
    for (final r in all) {
      if (!seen.contains(r.cuisineType)) {
        seen.add(r.cuisineType);
        uniqueByCuisine.add(r);
      }
    }
    return uniqueByCuisine;
  }

  // ✅ Fetch top-rated restaurants
  Future<List<RestaurantModel>> fetchRecommendations() async {
    final snapshot = await firestore
        .collection('restaurants')
        .orderBy('rating', descending: true)
        .limit(5)
        .get();

    return snapshot.docs
        .map((doc) => RestaurantModel.fromFirestore(doc))
        .toList();
  }

  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    try {
      Query query = firestore.collection('restaurants');

      print('running getRestaurantsSSSS');
      // Optional filters
      if (cuisineType != null && cuisineType.isNotEmpty) {
        query = query.where('cuisineType', isEqualTo: cuisineType);
      }
      if (isHalal != null) {
        query = query.where('isHalal', isEqualTo: isHalal);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final restaurants = snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();

      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
    try {
      final doc = await firestore.collection('restaurants').doc(id).get();

      if (!doc.exists) {
        return Left(ServerFailure('Restaurant not found'));
      }

      final restaurant = RestaurantModel.fromFirestore(doc);

      return Right(restaurant);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }
}
