import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/vendor/data/datasources/vendor_remote_datasource.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_application_entity.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';
import 'package:makan_mate/services/activity_log_service.dart';
import 'package:makan_mate/services/notification_service.dart';

/// Implementation of VendorRepository
class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VendorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, VendorApplicationEntity>> createVendorApplication({
    required String userId,
    required String userName,
    required String email,
    required String businessName,
    required String businessType,
    String? businessDescription,
    String? phoneNumber,
    String? address,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final application = await remoteDataSource.createVendorApplication(
        userId: userId,
        userName: userName,
        email: email,
        businessName: businessName,
        businessType: businessType,
        businessDescription: businessDescription,
        phoneNumber: phoneNumber,
        address: address,
        additionalData: additionalData,
      );

      // Log activity
      await ActivityLogService().logVendorApplication(userId, userName);

      // Notify admin
      await NotificationService().notifyNewVendorApplication(businessName);

      // Check pending applications threshold
      await _checkPendingApplicationsThreshold();

      return Right(application);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VendorApplicationEntity>> getVendorApplication(
    String applicationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final application = await remoteDataSource.getVendorApplication(applicationId);
      return Right(application);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VendorApplicationEntity?>> getVendorApplicationByUserId(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final application = await remoteDataSource.getVendorApplicationByUserId(userId);
      return Right(application);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveVendorApplication({
    required String applicationId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.approveVendorApplication(
        applicationId: applicationId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectVendorApplication({
    required String applicationId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.rejectVendorApplication(
        applicationId: applicationId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Check pending applications threshold and notify if needed
  Future<void> _checkPendingApplicationsThreshold() async {
    try {
      // This would require access to Firestore, but we can call NotificationService directly
      // The actual count check can be done in the Admin feature or via a use case
      // For now, we'll just let the notification service handle it
      await NotificationService().notifyPendingApplicationsThreshold(0);
    } catch (e) {
      // Log error but don't fail the operation
      // In a real implementation, you might want to use a logger here
    }
  }
}

