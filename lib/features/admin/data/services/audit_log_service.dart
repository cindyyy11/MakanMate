import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Service for logging admin actions to audit log
class AuditLogService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;

  AuditLogService({
    required this.firestore,
    required this.auth,
    required this.logger,
  });

  /// Log an admin action to audit log
  Future<void> logAction({
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? details,
    String? reason,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        logger.w('Cannot log audit: No authenticated user');
        return;
      }

      // Get admin email from user document
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final adminEmail = userDoc.data()?['email'] ?? user.email ?? 'unknown';

      await firestore.collection('audit_logs').add({
        'adminId': user.uid,
        'adminEmail': adminEmail,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'details': details ?? {},
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': null, // Can be added if needed
        'userAgent': null, // Can be added if needed
      });

      logger.i('Audit log created: $action on $entityType $entityId');
    } catch (e, stackTrace) {
      logger.e('Error creating audit log: $e', stackTrace: stackTrace);
      // Don't throw - audit logging should not break the main flow
    }
  }

  /// Log vendor approval
  Future<void> logVendorApproval({
    required String vendorId,
    String? reason,
  }) async {
    await logAction(
      action: 'approve_vendor',
      entityType: 'vendor',
      entityId: vendorId,
      details: {
        'from': 'pending',
        'to': 'approved',
      },
      reason: reason,
    );
  }

  /// Log vendor rejection
  Future<void> logVendorRejection({
    required String vendorId,
    required String reason,
  }) async {
    await logAction(
      action: 'reject_vendor',
      entityType: 'vendor',
      entityId: vendorId,
      details: {
        'from': 'pending',
        'to': 'rejected',
      },
      reason: reason,
    );
  }

  /// Log review removal
  Future<void> logReviewRemoval({
    required String reviewId,
    required String reason,
  }) async {
    await logAction(
      action: 'remove_review',
      entityType: 'review',
      entityId: reviewId,
      details: {
        'from': 'active',
        'to': 'removed',
      },
      reason: reason,
    );
  }

  /// Log user ban
  Future<void> logUserBan({
    required String userId,
    required String reason,
    DateTime? banUntil,
  }) async {
    await logAction(
      action: 'ban_user',
      entityType: 'user',
      entityId: userId,
      details: {
        'from': 'active',
        'to': 'banned',
        'banUntil': banUntil?.toIso8601String(),
      },
      reason: reason,
    );
  }

  /// Log user warning
  Future<void> logUserWarning({
    required String userId,
    required String reason,
  }) async {
    await logAction(
      action: 'warn_user',
      entityType: 'user',
      entityId: userId,
      details: {
        'action': 'warning_issued',
      },
      reason: reason,
    );
  }

  /// Log system config change
  Future<void> logConfigChange({
    required String configKey,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    await logAction(
      action: 'update_config',
      entityType: 'system_config',
      entityId: configKey,
      details: {
        'from': oldValue.toString(),
        'to': newValue.toString(),
      },
      reason: 'System configuration updated',
    );
  }

  /// Log feature flag change
  Future<void> logFeatureFlagChange({
    required String featureId,
    required bool enabled,
    int? rolloutPercentage,
  }) async {
    await logAction(
      action: 'update_feature_flag',
      entityType: 'feature_flag',
      entityId: featureId,
      details: {
        'enabled': enabled,
        'rolloutPercentage': rolloutPercentage,
      },
      reason: 'Feature flag updated',
    );
  }
}

