import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_user_management_datasource.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/user_ban_entity.dart';

/// Implementation of admin user repository
class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserManagementDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminUserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({
    String? role,
    bool? isVerified,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final users = await remoteDataSource.getUsers(
        role: role,
        isVerified: isVerified,
        limit: limit,
      );
      // Convert models to entities
      final entities = users.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch users: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserById(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyUser({
    required String userId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.verifyUser(
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to verify user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> banUser({
    required String userId,
    required String reason,
    DateTime? banUntil,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.banUser(
        userId: userId,
        reason: reason,
        banUntil: banUntil,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to ban user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unbanUser({
    required String userId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.unbanUser(
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to unban user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> warnUser({
    required String userId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.warnUser(
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to warn user: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserViolationHistory(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final history = await remoteDataSource.getUserViolationHistory(userId);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch violation history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserData({
    required String userId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deleteUserData(
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete user data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserBanEntity>>> getBansAndWarnings({
    String? type,
    bool? isActive,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final bansAndWarnings = await remoteDataSource.getBansAndWarnings(
        type: type,
        isActive: isActive,
      );
      return Right(bansAndWarnings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bans and warnings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> liftBanOrWarning({
    required String banId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.liftBanOrWarning(
        banId: banId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to lift ban/warning: $e'));
    }
  }
}

