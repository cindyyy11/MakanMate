// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:makan_mate/core/errors/exceptions.dart';
// import 'package:makan_mate/features/home/data/models/restaurant_model.dart';
// import 'package:makan_mate/features/restaurant/data/models/restaurant_models.dart';

// abstract class RestaurantRemoteDataSource {
//   Future<List<RestaurantModel>> getRestaurants({
//     int? limit,
//     String? cuisineType,
//     bool? isHalal,
//   });

//   Future<RestaurantModel> getRestaurantById(String id);
//   Future<List<RestaurantModel>> fetchCategories();
//   Future<List<RestaurantModel>> fetchRecommendations();
// }

// class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
//   final FirebaseFirestore firestore;

//   RestaurantRemoteDataSourceImpl({required this.firestore});

//   @override
//   Future<List<RestaurantModel>> getRestaurants({
//     int? limit,
//     String? cuisineType,
//     bool? isHalal,
//   }) async {
//     try {
//       print('in getRestaurants');
//       Query query = firestore.collection('restaurants');

//       // Apply filters
//       if (cuisineType != null) {
//         query = query.where('cuisineType', arrayContains: cuisineType);
//       }

//       if (isHalal != null) {
//         query = query.where('isHalal', isEqualTo: isHalal);
//       }

//       // Apply limit
//       if (limit != null) {
//         query = query.limit(limit);
//       }

//       final snapshot = await query.get();

//       return snapshot.docs
//           .map((doc) => RestaurantModel.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       throw ServerException('Failed to fetch restaurants: ${e.toString()}');
//     }
//   }

//   @override
//   Future<RestaurantModel> getRestaurantById(String id) async {
//     try {
//       final doc = await firestore.collection('restaurants').doc(id).get();

//       if (!doc.exists) {
//         throw ServerException('Restaurant not found');
//       }

//       return RestaurantModel.fromFirestore(doc);
//     } catch (e) {
//       throw ServerException('Failed to fetch restaurant: ${e.toString()}');
//     }
//   }

//   // ✅ Fetch by category (grouped by cuisine)
//   Future<List<RestaurantModel>> fetchCategories() async {
//     final snapshot = await firestore.collection('restaurants').get();
//     final all = snapshot.docs
//         .map((doc) => RestaurantModel.fromFirestore(doc))
//         .toList();

//     // Optional: return one per cuisine
//     final seen = <String>{};
//     final uniqueByCuisine = <RestaurantModel>[];
//     for (final r in all) {
//       if (!seen.contains(r.cuisineType)) {
//         seen.add(r.cuisineType);
//         uniqueByCuisine.add(r);
//       }
//     }
//     return uniqueByCuisine;
//   }

//   // ✅ Fetch top-rated restaurants
//   Future<List<RestaurantModel>> fetchRecommendations() async {
//     final snapshot = await firestore
//         .collection('restaurants')
//         .orderBy('rating', descending: true)
//         .limit(5)
//         .get();

//     return snapshot.docs
//         .map((doc) => RestaurantModel.fromFirestore(doc))
//         .toList();
//   }
// }
