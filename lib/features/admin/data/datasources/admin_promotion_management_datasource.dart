import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';

/// Data source for promotion/voucher management operations
class AdminPromotionManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminPromotionManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get pending promotions from approval queue
  Future<List<Map<String, dynamic>>> getPendingPromotions() async {
    try {
      final snapshot = await firestore
          .collection('admin')
          .doc('approvals')
          .collection('promotions')
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> promotions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['approvalDocId'] = doc.id;
        promotions.add(data);
      }
      return promotions;
    } catch (e, stackTrace) {
      logger.e('Error fetching pending promotions: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all promotions for a vendor
  Future<List<Map<String, dynamic>>> getVendorPromotions(
    String vendorId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> promotions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['vendorId'] = vendorId;
        promotions.add(data);
      }
      return promotions;
    } catch (e, stackTrace) {
      logger.e('Error fetching vendor promotions: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Approve a promotion
  Future<void> approvePromotion({
    required String approvalDocId,
    required String vendorId,
    required String promotionId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update vendor's promotion status
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update({
            'status': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
            'approvedBy': adminId,
          });

      // Remove from approval queue
      await firestore
          .collection('admin')
          .doc('approvals')
          .collection('promotions')
          .doc(approvalDocId)
          .delete();

      // Log audit action
      await auditLogService.logAction(
        action: 'approve_promotion',
        entityType: 'promotion',
        entityId: promotionId,
        details: {'vendorId': vendorId},
        reason: reason ?? 'Promotion approved',
      );

      logger.i('Promotion $promotionId approved');
    } catch (e, stackTrace) {
      logger.e('Error approving promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reject a promotion
  Future<void> rejectPromotion({
    required String approvalDocId,
    required String vendorId,
    required String promotionId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update vendor's promotion status
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectedBy': adminId,
            'rejectionReason': reason,
          });

      // Remove from approval queue
      await firestore
          .collection('admin')
          .doc('approvals')
          .collection('promotions')
          .doc(approvalDocId)
          .delete();

      // Log audit action
      await auditLogService.logAction(
        action: 'reject_promotion',
        entityType: 'promotion',
        entityId: promotionId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Promotion $promotionId rejected');
    } catch (e, stackTrace) {
      logger.e('Error rejecting promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Edit a promotion (admin override)
  Future<void> editPromotion({
    required String vendorId,
    required String promotionId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();
      updates['lastEditedBy'] = adminId;
      updates['adminEdited'] = true;

      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update(updates);

      // Log audit action
      await auditLogService.logAction(
        action: 'edit_promotion',
        entityType: 'promotion',
        entityId: promotionId,
        details: {'vendorId': vendorId, 'updates': updates},
        reason: 'Admin edited promotion',
      );

      logger.i('Promotion $promotionId edited by admin');
    } catch (e, stackTrace) {
      logger.e('Error editing promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deactivate a promotion
  Future<void> deactivatePromotion({
    required String vendorId,
    required String promotionId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update({
            'status': 'deactivate',
            'deactivatedAt': FieldValue.serverTimestamp(),
            'deactivatedBy': adminId,
            'deactivationReason': reason,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'deactivate_promotion',
        entityType: 'promotion',
        entityId: promotionId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Promotion $promotionId deactivated');
    } catch (e, stackTrace) {
      logger.e('Error deactivating promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get expired promotions
  Future<List<Map<String, dynamic>>> getExpiredPromotions() async {
    try {
      final now = Timestamp.now();
      final vendorsSnapshot = await firestore.collection('vendors').get();

      List<Map<String, dynamic>> expiredPromotions = [];

      for (var vendorDoc in vendorsSnapshot.docs) {
        final promotionsSnapshot = await vendorDoc.reference
            .collection('promotions')
            .where('status', whereIn: ['approved', 'active'])
            .get();

        for (var promoDoc in promotionsSnapshot.docs) {
          final data = promoDoc.data();
          final expiryDate = data['expiryDate'] as Timestamp?;
          if (expiryDate != null && expiryDate.compareTo(now) < 0) {
            final promoData = data;
            promoData['id'] = promoDoc.id;
            promoData['vendorId'] = vendorDoc.id;
            expiredPromotions.add(promoData);
          }
        }
      }

      return expiredPromotions;
    } catch (e, stackTrace) {
      logger.e('Error fetching expired promotions: $e', stackTrace: stackTrace);
      return [];
    }
  }
}
