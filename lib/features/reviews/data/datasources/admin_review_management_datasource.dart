import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/reviews/data/models/admin_review_model.dart';

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
  Future<List<AdminReviewModel>> getFlaggedReviews({
    String? status,
    int? limit,
  }) async {
    try {
      // Query flagged reviews - filter by removed in memory to avoid index requirements
      Query query = firestore
          .collection('reviews')
          .where('flagged', isEqualTo: true);

      // Fetch more than limit if filtering in memory
      final fetchLimit = limit != null ? (limit * 2) : null;
      if (fetchLimit != null) {
        query = query.limit(fetchLimit);
      }

      final snapshot = await query.get();
      final List<AdminReviewModel> reviews = [];

      for (var doc in snapshot.docs) {
        try {
          final review = await AdminReviewModel.fromFirestore(doc, firestore);

          // Filter by removed status if status is provided
          // Note: status parameter is kept for backward compatibility but now maps to removed field
          if (status == 'resolved' || status == 'removed') {
            if (review.removed == true) {
              reviews.add(review);
            }
          } else if (status == 'pending') {
            if (review.removed != true) {
              reviews.add(review);
            }
          } else {
            // No status filter, add all flagged reviews
            reviews.add(review);
          }
        } catch (e) {
          logger.w('Error parsing flagged review ${doc.id}: $e');
        }
      }

      // Sort by flaggedAt descending (most recent first), fallback to createdAt
      reviews.sort((a, b) {
        final aDate = a.flaggedAt ?? a.createdAt;
        final bDate = b.flaggedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

      // Apply limit after filtering and sorting
      if (limit != null && reviews.length > limit) {
        return reviews.take(limit).toList();
      }

      return reviews;
    } catch (e) {
      logger.e('Error fetching flagged reviews: $e');
      return [];
    }
  }

  /// Get all reviews (for moderation)
  Future<List<AdminReviewModel>> getAllReviews({
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
      final List<AdminReviewModel> reviews = [];

      for (var doc in snapshot.docs) {
        try {
          final review = await AdminReviewModel.fromFirestore(doc, firestore);
          reviews.add(review);
        } catch (e) {
          logger.w('Error parsing review ${doc.id}: $e');
        }
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

      // Update review - unflag it
      await firestore.collection('reviews').doc(reviewId).update({
        'flagged': false,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': adminId,
        'moderationAction': 'approved',
      });

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

      // Update review - flag it
      await firestore.collection('reviews').doc(reviewId).update({
        'flagged': true,
        'flagReason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'flaggedBy': adminId,
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

  /// Dismiss a flagged review (mark as false positive - unflag it)
  Future<void> dismissFlaggedReview({
    required String reviewId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Unflag the review (mark as false positive)
      await firestore.collection('reviews').doc(reviewId).update({
        'flagged': false,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': adminId,
        'moderationAction': 'dismissed',
        'dismissalReason': reason ?? 'False positive',
      });

      // Log audit action
      await auditLogService.logAction(
        action: 'dismiss_flagged_review',
        entityType: 'review',
        entityId: reviewId,
        reason: reason ?? 'False positive',
      );

      logger.i('Flagged review $reviewId dismissed');
    } catch (e, stackTrace) {
      logger.e('Error dismissing flagged review: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
