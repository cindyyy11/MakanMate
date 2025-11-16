import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/vendor/data/models/vendor_profile_model.dart';
import 'package:makan_mate/features/vendor/data/models/menu_item_model.dart';

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
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        try {
          // Check if vendor is suspended and suspension period has expired
          // This check works for all queries, not just suspended ones
          final data = doc.data() as Map<String, dynamic>;
          final currentStatus = data['approvalStatus'] as String?;
          final suspendedUntil = data['suspendedUntil'] as Timestamp?;

          // Auto-reactivate if suspension period has expired (regardless of current query filter)
          if (currentStatus == 'suspended' && suspendedUntil != null) {
            final suspendUntilDate = suspendedUntil.toDate();
            if (suspendUntilDate.isBefore(now) ||
                suspendUntilDate.isAtSameMomentAs(now)) {
              // Suspension period expired - auto-reactivate
              try {
                await firestore.collection('vendors').doc(doc.id).update({
                  'approvalStatus': 'approved',
                  'updatedAt': FieldValue.serverTimestamp(),
                  // Clear suspension fields
                  'suspendedAt': FieldValue.delete(),
                  'suspendedBy': FieldValue.delete(),
                  'suspensionReason': FieldValue.delete(),
                  'suspendedUntil': FieldValue.delete(),
                });

                await auditLogService.logAction(
                  action: 'auto_reactivate_vendor',
                  entityType: 'vendor',
                  entityId: doc.id,
                  reason: 'Suspension period expired - auto-reactivated',
                );

                logger.i(
                  'Vendor ${doc.id} auto-reactivated (suspension expired at ${suspendUntilDate.toIso8601String()})',
                );
                // Skip this vendor as it's no longer suspended
                // If querying for suspended vendors, skip it
                if (approvalStatus == 'suspended') {
                  continue;
                }
                // If querying for approved vendors, it will now be included
              } catch (e) {
                logger.w('Error auto-reactivating vendor ${doc.id}: $e');
                // Continue to add vendor anyway
              }
            }
          }

          final model = await _getVendorWithMenuItems(doc);
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
          final model = await _getVendorWithMenuItems(doc);
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

  /// Activate a vendor (reactivate from suspended/deactivated)
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
        'approvalStatus':
            'approved', // Set to 'approved' so vendor appears in Active tab
        'activatedAt': FieldValue.serverTimestamp(),
        'activatedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
        // Clear suspension/deactivation fields
        'suspendedAt': FieldValue.delete(),
        'suspendedBy': FieldValue.delete(),
        'suspensionReason': FieldValue.delete(),
        'suspendedUntil': FieldValue.delete(),
        'deactivatedAt': FieldValue.delete(),
        'deactivatedBy': FieldValue.delete(),
        'deactivationReason': FieldValue.delete(),
      });

      await auditLogService.logAction(
        action: 'activate_vendor',
        entityType: 'vendor',
        entityId: vendorId,
        reason: reason ?? 'Vendor reactivated by admin',
      );

      logger.i('Vendor $vendorId reactivated');
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

  /// Helper method to fetch vendor with menu items from menus subcollection
  Future<VendorProfileModel> _getVendorWithMenuItems(
    DocumentSnapshot doc,
  ) async {
    final model = VendorProfileModel.fromFirestore(doc);

    // Fetch menu items from vendors/{vendorId}/menus collection
    try {
      final menuSnapshot = await firestore
          .collection('vendors')
          .doc(doc.id)
          .collection('menus')
          .get();

      final menuItems = menuSnapshot.docs.map((menuDoc) {
        final menuData = Map<String, dynamic>.from(menuDoc.data());
        menuData['id'] = menuDoc.id;
        // Create MenuItemModel from document data
        return MenuItemModel.fromMap(menuData);
      }).toList();

      // Return model with menu items
      return VendorProfileModel(
        id: model.id,
        profilePhotoUrl: model.profilePhotoUrl,
        businessLogoUrl: model.businessLogoUrl,
        bannerImageUrl: model.bannerImageUrl,
        businessName: model.businessName,
        cuisineType: model.cuisineType,
        contactNumber: model.contactNumber,
        emailAddress: model.emailAddress,
        businessAddress: model.businessAddress,
        shortDescription: model.shortDescription,
        priceRange: model.priceRange,
        ratingAverage: model.ratingAverage,
        approvalStatus: model.approvalStatus,
        operatingHours: model.operatingHours,
        outlets: model.outlets,
        certifications: model.certifications,
        menuItems: menuItems,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        rejectedAt: model.rejectedAt,
        rejectedBy: model.rejectedBy,
        rejectionReason: model.rejectionReason,
      );
    } catch (e) {
      logger.w('Error fetching menu items for vendor ${doc.id}: $e');
      return model;
    }
  }
}
