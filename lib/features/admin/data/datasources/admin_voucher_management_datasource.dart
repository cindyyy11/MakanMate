import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/vendor/data/models/promotion_model.dart';

/// Wrapper class to include vendor info with promotion
class PromotionWithVendorInfo {
  final PromotionModel promotion;
  final String vendorId;

  PromotionWithVendorInfo({required this.promotion, required this.vendorId});
}

/// Data source for voucher management operations
class AdminVoucherManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminVoucherManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get pending promotions (vouchers) from all vendors
  Future<List<PromotionWithVendorInfo>> getPendingVouchers() async {
    try {
      // Use collection group query to get all promotions across all vendors
      // Note: This requires a Firestore index on promotions collection group
      // Index: collection group 'promotions', fields: status (Ascending), createdAt (Descending)
      Query query = firestore
          .collectionGroup('promotions')
          .where('status', isEqualTo: 'pending');

      // Try to order by createdAt, but handle if index doesn't exist
      try {
        query = query.orderBy('createdAt', descending: true);
      } catch (e) {
        logger.w('Could not order by createdAt, will sort in memory: $e');
      }

      final snapshot = await query.get();
      final List<PromotionWithVendorInfo> promotions = [];

      for (var promoDoc in snapshot.docs) {
        try {
          // Extract vendorId from document reference path
          // Path format: vendors/{vendorId}/promotions/{promoId}
          final pathParts = promoDoc.reference.path.split('/');
          final vendorIdIndex = pathParts.indexOf('vendors');
          if (vendorIdIndex == -1 || vendorIdIndex + 1 >= pathParts.length) {
            logger.w(
              'Could not extract vendorId from path: ${promoDoc.reference.path}',
            );
            continue;
          }
          final vendorId = pathParts[vendorIdIndex + 1];

          final data = promoDoc.data();
          if (data == null) continue;
          final promoData = Map<String, dynamic>.from(data as Map);
          promoData['id'] = promoDoc.id;

          // Convert to PromotionModel
          final promotion = PromotionModel.fromMap(promoData);
          promotions.add(
            PromotionWithVendorInfo(promotion: promotion, vendorId: vendorId),
          );
        } catch (e) {
          logger.w('Error parsing promotion ${promoDoc.id}: $e');
        }
      }

      // Sort by createdAt descending (most recent first) if not already sorted
      promotions.sort(
        (a, b) => b.promotion.createdAt.compareTo(a.promotion.createdAt),
      );

      return promotions;
    } catch (e, stackTrace) {
      logger.e('Error fetching pending vouchers: $e', stackTrace: stackTrace);
      // Fallback: query each vendor individually if collection group query fails
      return _getPendingVouchersFallback();
    }
  }

  /// Fallback method to get pending vouchers by querying each vendor individually
  Future<List<PromotionWithVendorInfo>> _getPendingVouchersFallback() async {
    try {
      // Get all vendors
      final vendorsSnapshot = await firestore.collection('vendors').get();
      final List<PromotionWithVendorInfo> promotions = [];

      // Query promotions from each vendor where status is 'pending'
      for (var vendorDoc in vendorsSnapshot.docs) {
        try {
          final vendorId = vendorDoc.id;
          final promotionsSnapshot = await firestore
              .collection('vendors')
              .doc(vendorId)
              .collection('promotions')
              .where('status', isEqualTo: 'pending')
              .get();

          for (var promoDoc in promotionsSnapshot.docs) {
            try {
              final promoData = Map<String, dynamic>.from(promoDoc.data());
              promoData['id'] = promoDoc.id;

              // Convert to PromotionModel
              final promotion = PromotionModel.fromMap(promoData);
              promotions.add(
                PromotionWithVendorInfo(
                  promotion: promotion,
                  vendorId: vendorId,
                ),
              );
            } catch (e) {
              logger.w(
                'Error parsing promotion ${promoDoc.id} for vendor $vendorId: $e',
              );
            }
          }
        } catch (e) {
          logger.w('Error fetching promotions for vendor ${vendorDoc.id}: $e');
        }
      }

      // Sort by createdAt descending (most recent first)
      promotions.sort(
        (a, b) => b.promotion.createdAt.compareTo(a.promotion.createdAt),
      );

      return promotions;
    } catch (e) {
      logger.e('Error in fallback method for fetching pending vouchers: $e');
      return [];
    }
  }

  /// Get all promotions (vouchers) for a vendor
  Future<List<PromotionModel>> getVendorVouchers(String vendorId) async {
    try {
      final snapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .orderBy('createdAt', descending: true)
          .get();

      final List<PromotionModel> promotions = [];
      for (var doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;

          final promotion = PromotionModel.fromMap(data);
          promotions.add(promotion);
        } catch (e) {
          logger.w('Error parsing promotion ${doc.id}: $e');
        }
      }
      return promotions;
    } catch (e, stackTrace) {
      logger.e('Error fetching vendor promotions: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Approve a promotion (voucher)
  Future<void> approveVoucher({
    required String vendorId,
    required String voucherId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update promotion status to approved
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(voucherId)
          .update({
            'status': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
            'approvedBy': adminId,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'approve_promotion',
        entityType: 'promotion',
        entityId: voucherId,
        details: {'vendorId': vendorId},
        reason: reason ?? 'Promotion approved',
      );

      logger.i('Promotion $voucherId approved for vendor $vendorId');
    } catch (e, stackTrace) {
      logger.e('Error approving promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reject a promotion (voucher)
  Future<void> rejectVoucher({
    required String vendorId,
    required String voucherId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update promotion status to rejected
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(voucherId)
          .update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectedBy': adminId,
            'rejectionReason': reason,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'reject_promotion',
        entityType: 'promotion',
        entityId: voucherId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Promotion $voucherId rejected for vendor $vendorId');
    } catch (e, stackTrace) {
      logger.e('Error rejecting promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Edit a promotion (voucher) - admin override
  Future<void> editVoucher({
    required String vendorId,
    required String voucherId,
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
          .doc(voucherId)
          .update(updates);

      // Log audit action
      await auditLogService.logAction(
        action: 'edit_promotion',
        entityType: 'promotion',
        entityId: voucherId,
        details: {'vendorId': vendorId, 'updates': updates},
        reason: 'Admin edited promotion',
      );

      logger.i('Promotion $voucherId edited by admin');
    } catch (e, stackTrace) {
      logger.e('Error editing promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deactivate a promotion (voucher)
  Future<void> deactivateVoucher({
    required String vendorId,
    required String voucherId,
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
          .doc(voucherId)
          .update({
            'status': 'deactivated',
            'deactivatedAt': FieldValue.serverTimestamp(),
            'deactivatedBy': adminId,
            'deactivationReason': reason,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'deactivate_promotion',
        entityType: 'promotion',
        entityId: voucherId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Promotion $voucherId deactivated for vendor $vendorId');
    } catch (e, stackTrace) {
      logger.e('Error deactivating promotion: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
