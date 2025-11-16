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
  Stream<List<ReviewEntity>> watchRestaurantReviews(String vendorId) {
    return firestore
        .collection(reviewsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .asyncMap((snap) async {
      // Use fallback logic for every review
      final reviews = await Future.wait(
        snap.docs.map((d) => _mapDocToEntityWithFallback(d)),
      );

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
      "vendorReply": {
        "text": replyText,
        "createdAt": FieldValue.serverTimestamp(),
      },
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    await firestore.collection(reviewReportsCollection).add({
      "reviewId": reviewId,
      "reason": reason,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<ReviewEntity?> getLatestReview(String vendorId) async {
    final snap = await firestore
        .collection(reviewsCollection)
        .where("vendorId", isEqualTo: vendorId)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    // Also use fallback logic here
    return _mapDocToEntityWithFallback(snap.docs.first);
  }

  Future<ReviewEntity> _mapDocToEntityWithFallback(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data() ?? {};
    final vendorReply = data['vendorReply'];

    final userId = data['userId'] ?? '';

    String userName = data['userName'] ??
        data['userDisplayName'] ??
        data['name'] ??
        '';

    if (userName.isEmpty && userId.isNotEmpty) {
      final userSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data()!;
        userName = userData['name'] ??
            userData['displayName'] ??
            userData['username'] ??
            'Customer';
      } else {
        userName = 'Customer';
      }
    } else if (userName.isEmpty) {
      userName = 'Anonymous';
    }

    return ReviewEntity(
      id: doc.id,
      userId: userId,
      userName: userName,
      itemId: data['itemId'] ?? '',
      restaurantId: data['vendorId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      aspectRatings: Map<String, double>.from(
        (data['aspectRatings'] ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      tags: List<String>.from(data['tags'] ?? []),
      helpfulCount: data['helpfulCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      vendorReplyText: vendorReply?['text'],
      vendorReplyAt: vendorReply?['createdAt']?.toDate(),
    );
  }

  ReviewEntity _mapDocToEntity(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final vendorReply = data['vendorReply'];

    return ReviewEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ??
          data['userDisplayName'] ??
          data['name'] ??
          'Anonymous',
      itemId: data['itemId'] ?? '',
      restaurantId: data['vendorId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      aspectRatings: Map<String, double>.from(
        (data['aspectRatings'] ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      tags: List<String>.from(data['tags'] ?? []),
      helpfulCount: data['helpfulCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      vendorReplyText: vendorReply?['text'],
      vendorReplyAt: vendorReply?['createdAt']?.toDate(),
    );
  }
}
