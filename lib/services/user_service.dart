import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/models/user_models.dart';
import 'package:makan_mate/services/base_service.dart';



class UserService extends BaseService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String COLLECTION_NAME = 'users';
  static const String INTERACTIONS_COLLECTION = 'user_interactions';

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      await BaseService.firestore.collection(COLLECTION_NAME).doc(user.id).set(user.toJson());
      BaseService.logger.i('User created: ${user.id}');
    } catch (e) {
      BaseService.logger.e('Error creating user: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await BaseService.firestore.collection(COLLECTION_NAME).doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      BaseService.logger.e('Error getting user: $e');
      return null;
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await BaseService.firestore
          .collection(COLLECTION_NAME)
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toJson());
      
      BaseService.logger.i('User updated: ${user.id}');
    } catch (e) {
      BaseService.logger.e('Error updating user: $e');
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences({
    required String userId,
    Map<String, double>? cuisinePreferences,
    List<String>? dietaryRestrictions,
    double? spiceTolerance,
    String? culturalBackground,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (cuisinePreferences != null) {
        updates['cuisinePreferences'] = cuisinePreferences;
      }
      
      if (dietaryRestrictions != null) {
        updates['dietaryRestrictions'] = dietaryRestrictions;
      }
      
      if (spiceTolerance != null) {
        updates['spiceTolerance'] = spiceTolerance;
      }
      
      if (culturalBackground != null) {
        updates['culturalBackground'] = culturalBackground;
      }

      await BaseService.firestore.collection(COLLECTION_NAME).doc(userId).update(updates);
      
      BaseService.logger.i('User preferences updated: $userId');
    } catch (e) {
      BaseService.logger.e('Error updating user preferences: $e');
      rethrow;
    }
  }

  // Update behavioral patterns
  Future<void> updateBehavioralPatterns(
    String userId,
    Map<String, double> behaviorPatterns,
  ) async {
    try {
      await BaseService.firestore.collection(COLLECTION_NAME).doc(userId).update({
        'behaviorPatterns': behaviorPatterns,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      BaseService.logger.e('Error updating behavioral patterns: $e');
      rethrow;
    }
  }

  // Track user interaction
  Future<void> trackInteraction({
    required String userId,
    required String itemId,
    required String interactionType,
    double? rating,
    String? comment,
    Map<String, dynamic>? context,
  }) async {
    try {
      final interaction = UserInteraction(
        id: '', // Firestore will generate
        userId: userId,
        itemId: itemId,
        interactionType: interactionType,
        rating: rating,
        comment: comment,
        context: context ?? {},
        timestamp: DateTime.now(),
      );

      await BaseService.firestore.collection(INTERACTIONS_COLLECTION).add(interaction.toJson());
      
      BaseService.logger.i('Interaction tracked: $userId -> $itemId ($interactionType)');
    } catch (e) {
      BaseService.logger.e('Error tracking interaction: $e');
      rethrow;
    }
  }

  // Get user interactions
  Future<List<UserInteraction>> getUserInteractions(
    String userId, {
    int limit = 100,
  }) async {
    try {
      final query = await BaseService.firestore
          .collection(INTERACTIONS_COLLECTION)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserInteraction.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting user interactions: $e');
      return [];
    }
  }

  // Get interactions since timestamp
  Future<List<UserInteraction>> getInteractionsSince(DateTime since) async {
    try {
      final query = await BaseService.firestore
          .collection(INTERACTIONS_COLLECTION)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(since))
          .get();

      return query.docs.map((doc) => UserInteraction.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting interactions since: $e');
      return [];
    }
  }

  // Delete user data
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete user document
      await BaseService.firestore.collection(COLLECTION_NAME).doc(userId).delete();
      
      // Delete user interactions
      final interactions = await BaseService.firestore
          .collection(INTERACTIONS_COLLECTION)
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = BaseService.firestore.batch();
      for (var doc in interactions.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      BaseService.logger.i('User data deleted: $userId');
    } catch (e) {
      BaseService.logger.e('Error deleting user data: $e');
      rethrow;
    }
  }

  // Get active users (for model training)
  Future<List<String>> getActiveUsers({int limit = 1000}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: 7));
      
      final query = await BaseService.firestore
          .collection(INTERACTIONS_COLLECTION)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
          .get();

      Set<String> activeUserIds = {};
      for (var doc in query.docs) {
        activeUserIds.add(doc.data()['userId']);
      }

      return activeUserIds.take(limit).toList();
    } catch (e) {
      BaseService.logger.e('Error getting active users: $e');
      return [];
    }
  }

  // Get all users (for model training)
  Future<List<UserModel>> getAllUsers({int limit = 10000}) async {
    try {
      final query = await BaseService.firestore
          .collection(COLLECTION_NAME)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      BaseService.logger.e('Error getting all users: $e');
      return [];
    }
  }
}