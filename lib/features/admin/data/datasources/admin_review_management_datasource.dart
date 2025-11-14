import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';

/// Data source for review/comment moderation operations
class AdminReviewManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminReviewManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get flagged reviews
  Future<List<Map<String, dynamic>>> getFlaggedReviews({
    String? status,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('flagged_content')
          .where('contentType', isEqualTo: 'review')
          .orderBy('flaggedAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      } else {
        query = query.where('status', isEqualTo: 'pending');
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final List<Map<String, dynamic>> reviews = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['flagId'] = doc.id;
        reviews.add(data);
      }
      return reviews;
    } catch (e, stackTrace) {
      logger.e('Error fetching flagged reviews: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all reviews (for moderation)
  Future<List<Map<String, dynamic>>> getAllReviews({
    String? vendorId,
    bool? flaggedOnly,
    int? limit,
  }) async {
    try {
      Query query = firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true);

      if (vendorId != null) {
        query = query.where('vendorId', isEqualTo: vendorId);
      }

      if (flaggedOnly == true) {
        query = query.where('flagged', isEqualTo: true);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final List<Map<String, dynamic>> reviews = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        reviews.add(data);
      }
      return reviews;
    } catch (e, stackTrace) {
      logger.e('Error fetching reviews: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Approve a review (unflag it)
  Future<void> approveReview({required String reviewId, String? reason}) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update review
      await firestore.collection('reviews').doc(reviewId).update({
        'flagged': false,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': adminId,
        'moderationAction': 'approved',
      });

      // Update flagged_content if exists
      final flaggedSnapshot = await firestore
          .collection('flagged_content')
          .where('contentType', isEqualTo: 'review')
          .where('contentId', isEqualTo: reviewId)
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = firestore.batch();
      for (var doc in flaggedSnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'resolved',
          'resolvedAt': FieldValue.serverTimestamp(),
          'resolvedBy': adminId,
          'resolution': 'approved',
        });
      }
      await batch.commit();

      // Log audit action
      await auditLogService.logAction(
        action: 'approve_review',
        entityType: 'review',
        entityId: reviewId,
        reason: reason ?? 'Review approved',
      );

      logger.i('Review $reviewId approved');
    } catch (e, stackTrace) {
      logger.e('Error approving review: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Flag a review
  Future<void> flagReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update review
      await firestore.collection('reviews').doc(reviewId).update({
        'flagged': true,
        'flagReason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'flaggedBy': adminId,
      });

      // Create flagged_content entry
      await firestore.collection('flagged_content').add({
        'contentType': 'review',
        'contentId': reviewId,
        'reason': reason,
        'status': 'pending',
        'flaggedBy': adminId,
        'flaggedAt': FieldValue.serverTimestamp(),
      });

      // Log audit action
      await auditLogService.logAction(
        action: 'flag_review',
        entityType: 'review',
        entityId: reviewId,
        reason: reason,
      );

      logger.i('Review $reviewId flagged');
    } catch (e, stackTrace) {
      logger.e('Error flagging review: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Remove a review
  Future<void> removeReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Soft delete - mark as removed instead of deleting
      await firestore.collection('reviews').doc(reviewId).update({
        'removed': true,
        'removedAt': FieldValue.serverTimestamp(),
        'removedBy': adminId,
        'removalReason': reason,
        'flagged': false, // Unflag if was flagged
      });

      // Update flagged_content if exists
      final flaggedSnapshot = await firestore
          .collection('flagged_content')
          .where('contentType', isEqualTo: 'review')
          .where('contentId', isEqualTo: reviewId)
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = firestore.batch();
      for (var doc in flaggedSnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'resolved',
          'resolvedAt': FieldValue.serverTimestamp(),
          'resolvedBy': adminId,
          'resolution': 'removed',
        });
      }
      await batch.commit();

      // Log audit action
      await auditLogService.logReviewRemoval(
        reviewId: reviewId,
        reason: reason,
      );

      logger.i('Review $reviewId removed');
    } catch (e, stackTrace) {
      logger.e('Error removing review: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Dismiss a flagged review (mark as false positive)
  Future<void> dismissFlaggedReview({
    required String flagId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('flagged_content').doc(flagId).update({
        'status': 'dismissed',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': adminId,
        'resolution': 'dismissed',
        'dismissalReason': reason ?? 'False positive',
      });

      logger.i('Flagged review $flagId dismissed');
    } catch (e, stackTrace) {
      logger.e('Error dismissing flagged review: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
