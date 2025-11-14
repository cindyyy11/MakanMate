import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';

/// Data source for menu item/content management operations
class AdminMenuManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminMenuManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get pending menu items (waiting for approval)
  Future<List<Map<String, dynamic>>> getPendingMenuItems() async {
    try {
      final vendorsSnapshot = await firestore.collection('vendors').get();
      List<Map<String, dynamic>> pendingItems = [];

      for (var vendorDoc in vendorsSnapshot.docs) {
        final menuSnapshot = await vendorDoc.reference
            .collection('menu')
            .where('approvalStatus', isEqualTo: 'pending')
            .get();

        for (var itemDoc in menuSnapshot.docs) {
          final data = itemDoc.data();
          data['id'] = itemDoc.id;
          data['vendorId'] = vendorDoc.id;
          pendingItems.add(data);
        }
      }

      return pendingItems;
    } catch (e, stackTrace) {
      logger.e('Error fetching pending menu items: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get featured menu items
  Future<List<Map<String, dynamic>>> getFeaturedMenuItems({int? limit}) async {
    try {
      final vendorsSnapshot = await firestore.collection('vendors').get();
      List<Map<String, dynamic>> featuredItems = [];

      for (var vendorDoc in vendorsSnapshot.docs) {
        Query query = vendorDoc.reference
            .collection('menu')
            .where('featured', isEqualTo: true)
            .where('approvalStatus', isEqualTo: 'approved');

        if (limit != null && featuredItems.length >= limit) {
          break;
        }

        final menuSnapshot = await query.get();
        for (var itemDoc in menuSnapshot.docs) {
          final data = itemDoc.data() as Map<String, dynamic>;
          data['id'] = itemDoc.id;
          data['vendorId'] = vendorDoc.id;
          featuredItems.add(data);
        }
      }

      return featuredItems.take(limit ?? featuredItems.length).toList();
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching featured menu items: $e',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Approve a menu item
  Future<void> approveMenuItem({
    required String vendorId,
    required String menuItemId,
    bool? featured,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      final updates = <String, dynamic>{
        'approvalStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
      };

      if (featured != null) {
        updates['featured'] = featured;
      }

      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('menu')
          .doc(menuItemId)
          .update(updates);

      // Log audit action
      await auditLogService.logAction(
        action: 'approve_menu_item',
        entityType: 'menu_item',
        entityId: menuItemId,
        details: {'vendorId': vendorId, 'featured': featured ?? false},
        reason: reason ?? 'Menu item approved',
      );

      logger.i('Menu item $menuItemId approved');
    } catch (e, stackTrace) {
      logger.e('Error approving menu item: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reject a menu item
  Future<void> rejectMenuItem({
    required String vendorId,
    required String menuItemId,
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
          .collection('menu')
          .doc(menuItemId)
          .update({
            'approvalStatus': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectedBy': adminId,
            'rejectionReason': reason,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'reject_menu_item',
        entityType: 'menu_item',
        entityId: menuItemId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Menu item $menuItemId rejected');
    } catch (e, stackTrace) {
      logger.e('Error rejecting menu item: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Edit a menu item (admin override)
  Future<void> editMenuItem({
    required String vendorId,
    required String menuItemId,
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
          .collection('menu')
          .doc(menuItemId)
          .update(updates);

      // Log audit action
      await auditLogService.logAction(
        action: 'edit_menu_item',
        entityType: 'menu_item',
        entityId: menuItemId,
        details: {'vendorId': vendorId, 'updates': updates},
        reason: 'Admin edited menu item',
      );

      logger.i('Menu item $menuItemId edited by admin');
    } catch (e, stackTrace) {
      logger.e('Error editing menu item: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Set menu item as featured
  Future<void> setFeatured({
    required String vendorId,
    required String menuItemId,
    required bool featured,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('menu')
          .doc(menuItemId)
          .update({
            'featured': featured,
            'featuredAt': featured ? FieldValue.serverTimestamp() : null,
            'featuredBy': featured ? adminId : null,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Log audit action
      await auditLogService.logAction(
        action: featured ? 'feature_menu_item' : 'unfeature_menu_item',
        entityType: 'menu_item',
        entityId: menuItemId,
        details: {'vendorId': vendorId},
        reason:
            reason ??
            (featured ? 'Menu item featured' : 'Menu item unfeatured'),
      );

      logger.i('Menu item $menuItemId ${featured ? 'featured' : 'unfeatured'}');
    } catch (e, stackTrace) {
      logger.e('Error setting featured status: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deactivate a menu item
  Future<void> deactivateMenuItem({
    required String vendorId,
    required String menuItemId,
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
          .collection('menu')
          .doc(menuItemId)
          .update({
            'available': false,
            'deactivatedAt': FieldValue.serverTimestamp(),
            'deactivatedBy': adminId,
            'deactivationReason': reason,
          });

      // Log audit action
      await auditLogService.logAction(
        action: 'deactivate_menu_item',
        entityType: 'menu_item',
        entityId: menuItemId,
        details: {'vendorId': vendorId},
        reason: reason,
      );

      logger.i('Menu item $menuItemId deactivated');
    } catch (e, stackTrace) {
      logger.e('Error deactivating menu item: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
