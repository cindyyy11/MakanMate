import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/reviews/data/models/review_model.dart';

/// Remote data source interface for reviews
abstract class ReviewRemoteDataSource {
  Future<ReviewModel> submitReview({
    required String userId,
    required String userName,
    required String restaurantId,
    required String itemId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
  });

  Future<List<ReviewModel>> getRestaurantReviews(
    String restaurantId, {
    int limit = 50,
  });

  Future<List<ReviewModel>> getItemReviews(String itemId, {int limit = 50});

  Future<List<ReviewModel>> getUserReviews(String userId, {int limit = 50});

  Future<void> flagReview({
    required String reviewId,
    required String reason,
    String? reportedBy,
  });

  Future<void> markReviewAsHelpful(String reviewId);

  Future<void> deleteReview(String reviewId);
}

/// Implementation of ReviewRemoteDataSource
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ReviewModel> submitReview({
    required String userId,
    required String userName,
    required String restaurantId,
    required String itemId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
  }) async {
    try {
      final reviewData = {
        'userId': userId,
        'userName': userName,
        'restaurantId': restaurantId,
        'itemId': itemId,
        'rating': rating,
        'comment': comment ?? '',
        'imageUrls': imageUrls ?? [],
        'aspectRatings': aspectRatings ?? {},
        'tags': tags ?? [],
        'helpfulCount': 0,
        'isFlagged': false,
        'flagReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await firestore.collection('reviews').add(reviewData);

      // Get the created document
      final doc = await docRef.get();
      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to submit review: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getRestaurantReviews(
    String restaurantId, {
    int limit = 50,
  }) async {
    try {
      final query = await firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get restaurant reviews: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getItemReviews(
    String itemId, {
    int limit = 50,
  }) async {
    try {
      final query = await firestore
          .collection('reviews')
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get item reviews: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final query = await firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get user reviews: $e');
    }
  }

  @override
  Future<void> flagReview({
    required String reviewId,
    required String reason,
    String? reportedBy,
  }) async {
    try {
      // Update review
      await firestore.collection('reviews').doc(reviewId).update({
        'isFlagged': true,
        'flagReason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'reportedBy': reportedBy,
      });

      // Create flagged content entry
      await firestore.collection('flagged_content').add({
        'type': 'review',
        'reviewId': reviewId,
        'reason': reason,
        'status': 'pending',
        'reportedBy': reportedBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to flag review: $e');
    }
  }

  @override
  Future<void> markReviewAsHelpful(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to mark review as helpful: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw ServerException('Failed to delete review: $e');
    }
  }
}
