import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSource(this.firestore);

  // ✅ Fetch by category (grouped by cuisine)
  Future<List<RestaurantModel>> fetchCategories() async {
    final snapshot = await firestore.collection('restaurants').get();
    final all = snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();

    // Optional: return one per cuisine
    final seen = <String>{};
    final uniqueByCuisine = <RestaurantModel>[];
    for (final r in all) {
      if (!seen.contains(r.cuisine)) {
        seen.add(r.cuisine);
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

    return snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();
  }
}
