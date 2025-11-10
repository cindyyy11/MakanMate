import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/features/recommendations/data/models/recommendation_models.dart';

/// Remote data source for recommendations using Firebase and AI engine
/// 
/// Coordinates between Firebase data and the TFLite model
abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationItem>> getRecommendations({
    required String userId,
    int limit = 10,
    RecommendationContext? context,
  });

  Future<List<RecommendationItem>> getContextualRecommendations({
    required String userId,
    required RecommendationContext context,
    int limit = 10,
  });

  Future<List<RecommendationItem>> getSimilarItems({
    required String itemId,
    int limit = 10,
  });

  Future<void> trackInteraction({
    required String userId,
    required String itemId,
    required String interactionType,
    double? rating,
    Map<String, dynamic>? context,
  });

  Future<Map<String, dynamic>> getRecommendationStats({
    required String userId,
  });
}

/// Implementation of remote data source
class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final RecommendationEngine engine;
  final Logger logger;

  RecommendationRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.engine,
    required this.logger,
  });

  @override
  Future<List<RecommendationItem>> getRecommendations({
    required String userId,
    int limit = 10,
    RecommendationContext? context,
  }) async {
    try {
      logger.i('Fetching recommendations for user: $userId');

      // Ensure engine is initialized
      if (!engine.isModelLoaded) {
        await engine.initialize();
      }

      // Get recommendations from AI engine
      final recommendations = await engine.getRecommendations(
        userId: userId,
        limit: limit,
        context: context,
      );

      // Cache recommendations in Firestore for analytics
      await _cacheRecommendations(userId, recommendations);

      logger.i('Successfully fetched ${recommendations.length} recommendations');
      return recommendations;
    } on FirebaseException catch (e) {
      logger.e('Firebase error fetching recommendations: ${e.code} - ${e.message}');
      throw Exception('Failed to fetch recommendations: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('Error fetching recommendations: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch recommendations: $e');
    }
  }

  @override
  Future<List<RecommendationItem>> getContextualRecommendations({
    required String userId,
    required RecommendationContext context,
    int limit = 10,
  }) async {
    try {
      logger.i('Fetching contextual recommendations for user: $userId');

      // Ensure engine is initialized
      if (!engine.isModelLoaded) {
        await engine.initialize();
      }

      // Get contextual recommendations
      final recommendations = await engine.getRecommendations(
        userId: userId,
        limit: limit,
        context: context,
      );

      logger.i('Successfully fetched ${recommendations.length} contextual recommendations');
      return recommendations;
    } on FirebaseException catch (e) {
      logger.e('Firebase error fetching contextual recommendations: ${e.code}');
      throw Exception('Failed to fetch contextual recommendations: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('Error fetching contextual recommendations: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch contextual recommendations: $e');
    }
  }

  @override
  Future<List<RecommendationItem>> getSimilarItems({
    required String itemId,
    int limit = 10,
  }) async {
    try {
      logger.i('Fetching similar items for: $itemId');

      // Get item details
      final itemDoc = await firestore.collection('food_items').doc(itemId).get();
      
      if (!itemDoc.exists) {
        throw Exception('Item not found: $itemId');
      }

      // For similar items, we can use content-based filtering
      // This is a simplified implementation
      final itemData = itemDoc.data()!;
      final cuisineType = itemData['cuisineType'] as String;
      final categories = List<String>.from(itemData['categories'] ?? []);

      // Query similar items based on cuisine and categories
      QuerySnapshot snapshot = await firestore
          .collection('food_items')
          .where('cuisineType', isEqualTo: cuisineType)
          .where('isActive', isEqualTo: true)
          .orderBy('averageRating', descending: true)
          .limit(limit + 1) // +1 to exclude the source item
          .get();

      List<RecommendationItem> similarItems = [];
      
      for (var doc in snapshot.docs) {
        if (doc.id == itemId) continue; // Skip the source item
        
        // Calculate similarity score
        final docData = doc.data() as Map<String, dynamic>;
        final categoriesData = docData['categories'];
        final docCategories = categoriesData != null 
            ? List<String>.from(categoriesData as List)
            : <String>[];
        final categoryOverlap = categories
            .where((cat) => docCategories.contains(cat))
            .length;
        final similarityScore = categoryOverlap / categories.length.clamp(1, double.infinity);
        
        similarItems.add(RecommendationItem(
          itemId: doc.id,
          score: similarityScore,
          reason: 'Similar to item you viewed',
          algorithmType: 'content_similarity',
          confidence: 0.8,
          generatedAt: DateTime.now(),
        ));
      }

      logger.i('Found ${similarItems.length} similar items');
      return similarItems.take(limit).toList();
    } on FirebaseException catch (e) {
      logger.e('Firebase error fetching similar items: ${e.code}');
      throw Exception('Failed to fetch similar items: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('Error fetching similar items: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch similar items: $e');
    }
  }

  @override
  Future<void> trackInteraction({
    required String userId,
    required String itemId,
    required String interactionType,
    double? rating,
    Map<String, dynamic>? context,
  }) async {
    try {
      logger.i('Tracking interaction: $userId -> $itemId ($interactionType)');

      final interaction = {
        'userId': userId,
        'itemId': itemId,
        'interactionType': interactionType,
        'rating': rating,
        'context': context,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Store in Firestore
      await firestore.collection('user_interactions').add(interaction);

      // Update user's interaction count
      await firestore.collection('users').doc(userId).update({
        'totalInteractions': FieldValue.increment(1),
        'lastInteractionAt': FieldValue.serverTimestamp(),
      });

      // Update item's interaction stats
      await firestore.collection('food_items').doc(itemId).update({
        'totalInteractions': FieldValue.increment(1),
        if (rating != null) 'lastRating': rating,
      });

      logger.i('Successfully tracked interaction');
    } on FirebaseException catch (e) {
      logger.e('Firebase error tracking interaction: ${e.code}');
      throw Exception('Failed to track interaction: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('Error tracking interaction: $e', stackTrace: stackTrace);
      throw Exception('Failed to track interaction: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getRecommendationStats({
    required String userId,
  }) async {
    try {
      logger.i('Fetching recommendation stats for user: $userId');

      // Get user's interaction history
      final interactions = await firestore
          .collection('user_interactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      // Calculate statistics
      final totalInteractions = interactions.docs.length;
      final interactionTypes = <String, int>{};
      var totalRating = 0.0;
      var ratingCount = 0;

      for (var doc in interactions.docs) {
        final data = doc.data();
        final type = data['interactionType'] as String;
        interactionTypes[type] = (interactionTypes[type] ?? 0) + 1;

        if (data['rating'] != null) {
          totalRating += (data['rating'] as num).toDouble();
          ratingCount++;
        }
      }

      final stats = {
        'totalInteractions': totalInteractions,
        'interactionTypes': interactionTypes,
        'averageRating': ratingCount > 0 ? totalRating / ratingCount : 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      logger.i('Successfully fetched recommendation stats');
      return stats;
    } on FirebaseException catch (e) {
      logger.e('Firebase error fetching stats: ${e.code}');
      throw Exception('Failed to fetch recommendation stats: ${e.message}');
    } catch (e, stackTrace) {
      logger.e('Error fetching stats: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch recommendation stats: $e');
    }
  }

  /// Cache recommendations for analytics and performance
  Future<void> _cacheRecommendations(
    String userId,
    List<RecommendationItem> recommendations,
  ) async {
    try {
      final cacheDoc = firestore
          .collection('recommendation_cache')
          .doc(userId);

      await cacheDoc.set({
        'userId': userId,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'generatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 1)),
        ),
      });
    } catch (e) {
      // Don't throw on cache failures
      logger.w('Failed to cache recommendations: $e');
    }
  }
}

