import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage user favorites/bookmarks
class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Toggle favorite status for an item
  Future<bool> toggleFavorite({
    required String itemId,
    required String itemName,
    required String itemType,
    String? imageUrl,
    double? price,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final favRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(itemId);

    final doc = await favRef.get();

    if (doc.exists) {
      // Remove from favorites
      await favRef.delete();
      return false;
    } else {
      // Add to favorites
      await favRef.set({
        'itemId': itemId,
        'itemName': itemName,
        'itemType': itemType,
        'imageUrl': imageUrl,
        'price': price,
        'addedAt': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
      return true;
    }
  }

  /// Check if an item is favorited
  Future<bool> isFavorite(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(itemId)
        .get();

    return doc.exists;
  }

  /// Watch favorite status for an item (real-time)
  Stream<bool> watchFavoriteStatus(String itemId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(itemId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Get all favorites for current user
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Remove a favorite
  Future<void> removeFavorite(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(itemId)
        .delete();
  }
}

