import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/vendor/domain/entities/review_entity.dart';
import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';
import 'package:makan_mate/services/base_service.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  static const String reviewsCollection = 'reviews';
  static const String reviewReportsCollection = 'review_reports';

  final FirebaseFirestore firestore;
  ReviewRepositoryImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? BaseService.firestore;

  @override
  Stream<List<ReviewEntity>> watchRestaurantReviews(String restaurantId) {
    // Query without orderBy to avoid index requirement, then sort manually
    return firestore
        .collection(reviewsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snap) {
          final reviews = snap.docs.map(_mapDocToEntity).toList();
          // Sort by createdAt descending (newest first)
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  @override
  Future<void> replyToReview({
    required String reviewId,
    required String replyText,
  }) async {
    await firestore.collection(reviewsCollection).doc(reviewId).update({
      'vendorReply': {
        'text': replyText,
        'createdAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    await firestore.collection(reviewReportsCollection).add({
      'reviewId': reviewId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  ReviewEntity _mapDocToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final vendorReply = data['vendorReply'] as Map<String, dynamic>?;
    return ReviewEntity(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      itemId: (data['itemId'] ?? '') as String,
      restaurantId: (data['restaurantId'] ?? '') as String,
      rating: (data['rating'] ?? 0).toDouble(),
      comment: (data['comment'] ?? '') as String,
      imageUrls: List<String>.from(data['imageUrls'] ?? const []),
      aspectRatings: Map<String, double>.from(
          (data['aspectRatings'] ?? const <String, dynamic>{})
              .map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))),
      tags: List<String>.from(data['tags'] ?? const []),
      helpfulCount: (data['helpfulCount'] ?? 0) as int,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      vendorReplyText: vendorReply?['text'] as String?,
      vendorReplyAt:
          vendorReply != null ? _toDateTime(vendorReply['createdAt']) : null,
    );
  }

  DateTime _toDateTime(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}


