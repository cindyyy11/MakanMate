import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';

/// Remote data source interface for user profile management
abstract class UserRemoteDataSource {
  /// Get user by ID
  Future<UserModel> getUser(String userId);

  /// Update user profile
  Future<UserModel> updateUser(UserModel user);

  /// Update user preferences
  Future<void> updateUserPreferences({
    required String userId,
    Map<String, double>? cuisinePreferences,
    List<String>? dietaryRestrictions,
    double? spiceTolerance,
    String? culturalBackground,
  });

  /// Update behavioral patterns
  Future<void> updateBehavioralPatterns({
    required String userId,
    required Map<String, double> behaviorPatterns,
  });
}

/// Implementation of UserRemoteDataSource
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String usersCollection = 'users';

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await firestore.collection(usersCollection).doc(userId).get();

      if (!doc.exists) {
        throw ServerException('User not found: $userId');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final updateData = updatedUser.toJson();

      // Convert DateTime to Timestamp for Firestore
      updateData['createdAt'] = Timestamp.fromDate(updatedUser.createdAt);
      updateData['updatedAt'] = Timestamp.fromDate(updatedUser.updatedAt);
      updateData['lastActive'] = FieldValue.serverTimestamp();

      await firestore
          .collection(usersCollection)
          .doc(user.id)
          .update(updateData);

      // Get updated user
      final doc = await firestore.collection(usersCollection).doc(user.id).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update user: $e');
    }
  }

  @override
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

      await firestore.collection(usersCollection).doc(userId).update(updates);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> updateBehavioralPatterns({
    required String userId,
    required Map<String, double> behaviorPatterns,
  }) async {
    try {
      await firestore.collection(usersCollection).doc(userId).update({
        'behaviorPatterns': behaviorPatterns,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update behavioral patterns: $e');
    }
  }
}

