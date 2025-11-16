import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/admin/domain/entities/user_ban_entity.dart';

/// Data source for user management operations
class AdminUserManagementDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Logger logger;
  final AuditLogService auditLogService;

  AdminUserManagementDataSource({
    required this.firestore,
    required this.auth,
    required this.logger,
    required this.auditLogService,
  });

  /// Get all users
  Future<List<UserModel>> getUsers({
    String? role,
    bool? isVerified,
    int? limit,
  }) async {
    try {
      Query query = firestore.collection('users');

      // Filter by role if provided
      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }

      // Filter by verification status if provided
      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        try {
          final model = UserModel.fromFirestore(doc);
          users.add(model);
        } catch (e) {
          logger.w('Error parsing user ${doc.id}: $e');
          // Skip invalid user documents
        }
      }
      return users;
    } catch (e, stackTrace) {
      logger.e('Error fetching users: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get a specific user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e, stackTrace) {
      logger.e('Error fetching user $userId: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// Verify a user account
  Future<void> verifyUser({
    required String userId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('users').doc(userId).update({
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'verify_user',
        entityType: 'user',
        entityId: userId,
        reason: reason ?? 'User verified by admin',
      );

      logger.i('User $userId verified');
    } catch (e, stackTrace) {
      logger.e('Error verifying user: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Ban a user
  Future<void> banUser({
    required String userId,
    required String reason,
    DateTime? banUntil,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': adminId,
        'banReason': reason,
        'bannedUntil': banUntil != null
            ? Timestamp.fromDate(banUntil)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'ban_user',
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );

      logger.i('User $userId banned');
    } catch (e, stackTrace) {
      logger.e('Error banning user: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Unban a user
  Future<void> unbanUser({
    required String userId,
    String? reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      await firestore.collection('users').doc(userId).update({
        'isBanned': false,
        'unbannedAt': FieldValue.serverTimestamp(),
        'unbannedBy': adminId,
        'unbanReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'unban_user',
        entityType: 'user',
        entityId: userId,
        reason: reason ?? 'User unbanned by admin',
      );

      logger.i('User $userId unbanned');
    } catch (e, stackTrace) {
      logger.e('Error unbanning user: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Warn a user
  Future<void> warnUser({
    required String userId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Add warning to user's warnings array
      await firestore.collection('users').doc(userId).update({
        'warnings': FieldValue.arrayUnion([
          {
            'reason': reason,
            'warnedBy': adminId,
            'warnedAt': FieldValue.serverTimestamp(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'warn_user',
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );

      logger.i('User $userId warned');
    } catch (e, stackTrace) {
      logger.e('Error warning user: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get user violation history
  Future<List<Map<String, dynamic>>> getUserViolationHistory(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('audit_logs')
          .where('entityType', isEqualTo: 'user')
          .where('entityId', isEqualTo: userId)
          .where('action', whereIn: ['ban_user', 'warn_user', 'remove_review'])
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching violation history: $e',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Delete user data (PDPA compliance)
  Future<void> deleteUserData({
    required String userId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      // Mark user as deleted (soft delete)
      await firestore.collection('users').doc(userId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': adminId,
        'deletionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'delete_user_data',
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );

      logger.i('User data $userId deleted');
    } catch (e, stackTrace) {
      logger.e('Error deleting user data: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get all bans (from users collection)
  Future<List<UserBanEntity>> getBansAndWarnings({
    String? type,
    bool? isActive,
  }) async {
    try {
      // We only support bans via users collection for now.
      // Warnings are stored on user doc in 'warnings' but this endpoint returns bans list.
      Query query = firestore.collection('users').where('isBanned', isEqualTo: true);

      // Active filter (based on bannedUntil)
      if (isActive != null) {
        // We'll filter client-side after fetching since Firestore where on computed isn't trivial
      }

      query = query.orderBy('bannedAt', descending: true).limit(100);

      final snapshot = await query.get();
      final List<UserBanEntity> bans = [];

      for (var doc in snapshot.docs) {
        try {
          final user = UserModel.fromFirestore(doc);

          // Determine active state based on bannedUntil and isBanned
          bool currentlyActive = user.isBanned;
          if (user.bannedUntil != null && DateTime.now().isAfter(user.bannedUntil!)) {
            currentlyActive = false;
          }

          // Apply isActive filter if provided
          if (isActive != null && currentlyActive != isActive) {
            continue;
          }

          final ban = UserBanEntity(
            id: user.id, // using user id as the ban id
            userId: user.id,
            userName: user.name,
            userEmail: user.email,
            userProfileImageUrl: user.profileImageUrl,
            type: 'ban',
            reason: user.banReason ?? '',
            details: null,
            createdAt: user.bannedAt ?? user.createdAt,
            expiresAt: user.bannedUntil,
            isActive: currentlyActive,
            adminId: user.bannedBy ?? '',
            adminName: null,
          );

          bans.add(ban);
        } catch (e) {
          logger.w('Error parsing banned user ${doc.id}: $e');
        }
      }

      logger.i('Fetched ${bans.length} banned users');
      return bans;
    } catch (e, stackTrace) {
      logger.e('Error fetching banned users: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Lift a ban or remove a warning
  Future<void> liftBanOrWarning({
    required String banId,
    required String reason,
  }) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }
      // With users collection approach, banId is the userId
      final userId = banId;
      await firestore.collection('users').doc(userId).update({
        'isBanned': false,
        'unbannedAt': FieldValue.serverTimestamp(),
        'unbannedBy': adminId,
        'unbanReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await auditLogService.logAction(
        action: 'lift_ban',
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );

      logger.i('Ban for user $userId lifted');
    } catch (e, stackTrace) {
      logger.e('Error lifting ban: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}

