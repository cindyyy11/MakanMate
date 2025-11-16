import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/features/search/data/models/search_food_model.dart';
import 'package:makan_mate/features/search/data/models/search_history_model.dart';
import 'package:makan_mate/features/search/data/models/search_restaurant_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchRestaurantModel>> searchRestaurants(String query);

  Future<List<SearchFoodModel>> searchFoods(String query);

  Future<List<SearchHistoryModel>> getSearchHistory();

  Future<void> addSearchHistory(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SearchRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? 'anonymous';

  @override
  Future<List<SearchRestaurantModel>> searchRestaurants(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();

    // 1. Get approved vendors
    final snapshot = await firestore
        .collection('vendors')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    // 2. Client-side filter by businessName / cuisineType
    final List<SearchRestaurantModel> results = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = (data['businessName'] ?? '').toString().toLowerCase();
      final cuisine = (data['cuisineType'] ?? '').toString().toLowerCase();

      if (name.contains(lowerQuery) || cuisine.contains(lowerQuery)) {
        results.add(SearchRestaurantModel.fromDoc(doc));
      }
    }

    return results;
  }

  @override
  Future<List<SearchFoodModel>> searchFoods(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();

    // Get all menus via collectionGroup
    final menuSnapshot =
        await firestore.collectionGroup('menus').get(); // sub-collection "menu"

    final List<SearchFoodModel> results = [];

    for (final doc in menuSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();

      if (!name.contains(lowerQuery)) continue;

      // parent path: vendors/{vendorId}/menu/{menuId}
      final vendorId = doc.reference.parent.parent?.id;
      if (vendorId == null) continue;

      final vendorDoc =
          await firestore.collection('vendors').doc(vendorId).get();
      final vendorData = vendorDoc.data() as Map<String, dynamic>? ?? {};
      final vendorName = vendorData['businessName'] ?? '';

      results.add(SearchFoodModel.fromDoc(doc, vendorId, vendorName));
    }

    return results;
  }

  @override
  Future<List<SearchHistoryModel>> getSearchHistory() async {
    final snapshot = await firestore
        .collection('users')
        .doc(_userId)
        .collection('searchHistory')
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => SearchHistoryModel.fromDoc(doc))
        .toList();
  }

  @override
  Future<void> addSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final id = trimmed.toLowerCase(); 

    final docRef = firestore
        .collection('users')
        .doc(_userId)
        .collection('searchHistory')
        .doc(id);

    final model = SearchHistoryModel(id: id, query: trimmed);

    await docRef.set(model.toMap(), SetOptions(merge: true));
  }
}
