import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/vendor/data/models/vendor_profile_model.dart';

/// Data source for vendor management operations
class AdminVendorManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminVendorManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get all vendors with their approval status
  Future<List<VendorProfileModel>> getVendors({
    String? approvalStatus,
    int? limit,
  }) async {
    try {
      Query query = firestore.collection('vendors');

      // Filter by approvalStatus if provided
      if (approvalStatus != null) {
        query = query.where('approvalStatus', isEqualTo: approvalStatus);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final List<VendorProfileModel> vendors = [];
      for (var doc in snapshot.docs) {
        try {
          final model = VendorProfileModel.fromFirestore(doc);
          vendors.add(model);
        } catch (e) {
          logger.w('Error parsing vendor ${doc.id}: $e');
          // Skip invalid vendor documents
        }
      }
      return vendors;
    } catch (e, stackTrace) {
      logger.e('Error fetching vendors: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get pending vendor applications
  Future<List<VendorProfileModel>> getPendingVendorApplications() async {
    try {
      final snapshot = await firestore
          .collection('vendors')
          .where('approvalStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final List<VendorProfileModel> applications = [];
      for (var doc in snapshot.docs) {
        try {
          final model = VendorProfileModel.fromFirestore(doc);
          applications.add(model);
        } catch (e) {
          logger.w('Error parsing vendor application ${doc.id}: $e');
          // Skip invalid vendor documents
        }
      }
      return applications;
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching pending applications: $e',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Approve a vendor
  Future<void> approveVendor({required String vendorId, String? reason}) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Get admin email
      final adminDoc = await firestore.collection('users').doc(adminId).get();
      final adminEmail = adminDoc.data()?['email'] ?? 'unknown';

      // Update vendor approval status
      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log audit action
      await auditLogService.logVendorApproval(
        vendorId: vendorId,
        reason: reason ?? 'Vendor approved by admin',
      );

      logger.i('Vendor $vendorId approved by $adminEmail');
    } catch (e, stackTrace) {
      logger.e('Error approving vendor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reject a vendor application
  Future<void> rejectVendor({
    required String vendorId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Update vendor approval status
      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminId, // Store admin user ID
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log audit action
      await auditLogService.logVendorRejection(
        vendorId: vendorId,
        reason: reason,
      );

      logger.i('Vendor $vendorId rejected');
    } catch (e, stackTrace) {
      logger.e('Error rejecting vendor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Activate a vendor
  Future<void> activateVendor({
    required String vendorId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': 'active',
        'activatedAt': FieldValue.serverTimestamp(),
        'activatedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'activate_vendor',
        entityType: 'vendor',
        entityId: vendorId,
        reason: reason ?? 'Vendor activated by admin',
      );

      logger.i('Vendor $vendorId activated');
    } catch (e, stackTrace) {
      logger.e('Error activating vendor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deactivate a vendor
  Future<void> deactivateVendor({
    required String vendorId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': 'deactivate',
        'deactivatedAt': FieldValue.serverTimestamp(),
        'deactivatedBy': adminId,
        'deactivationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'deactivate_vendor',
        entityType: 'vendor',
        entityId: vendorId,
        reason: reason,
      );

      logger.i('Vendor $vendorId deactivated');
    } catch (e, stackTrace) {
      logger.e('Error deactivating vendor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Suspend a vendor
  Future<void> suspendVendor({
    required String vendorId,
    required String reason,
    DateTime? suspendUntil,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedBy': adminId,
        'suspensionReason': reason,
        'suspendedUntil': suspendUntil != null
            ? Timestamp.fromDate(suspendUntil)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'suspend_vendor',
        entityType: 'vendor',
        entityId: vendorId,
        reason: reason,
      );

      logger.i('Vendor $vendorId suspended');
    } catch (e, stackTrace) {
      logger.e('Error suspending vendor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
