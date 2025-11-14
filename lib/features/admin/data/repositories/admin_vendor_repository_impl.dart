import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_vendor_management_datasource.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

/// Implementation of admin vendor repository
class AdminVendorRepositoryImpl implements AdminVendorRepository {
  final AdminVendorManagementDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminVendorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<VendorProfileEntity>>> getVendors({
    String? approvalStatus,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final vendors = await remoteDataSource.getVendors(
        approvalStatus: approvalStatus,
        limit: limit,
      );
      // Convert models to entities
      final entities = vendors.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch vendors: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VendorProfileEntity>>>
      getPendingVendorApplications() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final applications =
          await remoteDataSource.getPendingVendorApplications();
      // Convert models to entities
      final entities = applications.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch pending applications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveVendor({
    required String vendorId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.approveVendor(
        vendorId: vendorId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to approve vendor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectVendor({
    required String vendorId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.rejectVendor(
        vendorId: vendorId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to reject vendor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> activateVendor({
    required String vendorId,
    String? reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.activateVendor(
        vendorId: vendorId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to activate vendor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateVendor({
    required String vendorId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deactivateVendor(
        vendorId: vendorId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to deactivate vendor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> suspendVendor({
    required String vendorId,
    required String reason,
    DateTime? suspendUntil,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.suspendVendor(
        vendorId: vendorId,
        reason: reason,
        suspendUntil: suspendUntil,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to suspend vendor: $e'));
    }
  }
}


