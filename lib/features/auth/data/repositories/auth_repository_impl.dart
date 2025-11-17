import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:makan_mate/services/activity_log_service.dart';
import 'package:makan_mate/services/metrics_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Convert UserModel to UserEntity
  UserEntity _toUserEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      role: model.role,
      displayName: model.name,
      photoUrl: model.profileImageUrl,
      isAnonymous: model.role == 'guest', // Guest users are anonymous
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.signInWithEmailPassword(
        email,
        password,
      );
      await localDataSource.cacheUser(user);

      // ✅ Call infrastructure services from Repository (Data layer)
      await ActivityLogService().logUserSignIn(user.id, user.name);
      await MetricsService().updateUserActivity(user.id);

      return Right(_toUserEntity(user));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
    String role = 'user',
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final user = await remoteDataSource.signUpWithEmailPassword(
        email,
        password,
        displayName,
        role,
      );
      await localDataSource.cacheUser(user);

      // ✅ Call infrastructure services from Repository (Data layer)
      await ActivityLogService().logUserSignUp(user.id, user.name);
      if (user.role == 'vendor') {
        await ActivityLogService().logVendorApplication(user.id, user.name);
      }
      await MetricsService().updateUserActivity(user.id);

      return Right(_toUserEntity(user));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user);

      // ✅ Call infrastructure services from Repository (Data layer)
      await ActivityLogService().logUserSignIn(user.id, user.name);
      await MetricsService().updateUserActivity(user.id);

      return Right(_toUserEntity(user));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAsGuest() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final user = await remoteDataSource.signInAsGuest();
      await localDataSource.cacheUser(user);

      // Log guest sign-in (optional)
      await ActivityLogService().logUserSignIn(user.id, 'Guest User');

      return Right(_toUserEntity(user));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    // STRICT: require online to guarantee server revoke
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Internet is required to sign out'));
    }
    try {
      await remoteDataSource.signOut(); // revoke session
      await localDataSource.clearCache(); // clear local only after success
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Cache-first for fast startup
      final cached = await localDataSource.getCachedUser();

      // Silent refresh (doesn't block response)
      () async {
        try {
          final remote = await remoteDataSource.getCurrentUser();
          if (remote != null) {
            await localDataSource.cacheUser(remote);
          }
        } catch (_) {
          // ignore refresh errors; cached value already returned
        }
      }();

      return Right(cached != null ? _toUserEntity(cached) : null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return Left(AuthFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to send password reset email'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges
      .map((userModel) => userModel != null ? _toUserEntity(userModel) : null);

  @override
  Future<void> deleteAccount(String uid) async {
    await FirebaseFirestore.instance.collection("vendors").doc(uid).delete();
    await FirebaseAuth.instance.currentUser?.delete();
  }
}
