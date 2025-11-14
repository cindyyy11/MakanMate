import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';

/// Repository interface for admin user management operations
abstract class AdminUserRepository {
  /// Get all users
  Future<Either<Failure, List<UserEntity>>> getUsers({
    String? role,
    bool? isVerified,
    int? limit,
  });

  /// Get a specific user by ID
  Future<Either<Failure, UserEntity?>> getUserById(String userId);

  /// Verify a user account
  Future<Either<Failure, void>> verifyUser({
    required String userId,
    String? reason,
  });

  /// Ban a user
  Future<Either<Failure, void>> banUser({
    required String userId,
    required String reason,
    DateTime? banUntil,
  });

  /// Unban a user
  Future<Either<Failure, void>> unbanUser({
    required String userId,
    String? reason,
  });

  /// Warn a user
  Future<Either<Failure, void>> warnUser({
    required String userId,
    required String reason,
  });

  /// Get user violation history
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserViolationHistory(
    String userId,
  );

  /// Delete user data (PDPA compliance)
  Future<Either<Failure, void>> deleteUserData({
    required String userId,
    required String reason,
  });
}


