import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

/// Repository interface for admin vendor management operations
abstract class AdminVendorRepository {
  /// Get all vendors with their approval status
  Future<Either<Failure, List<VendorProfileEntity>>> getVendors({
    String? approvalStatus,
    int? limit,
  });

  /// Get pending vendor applications
  Future<Either<Failure, List<VendorProfileEntity>>> getPendingVendorApplications();

  /// Approve a vendor
  Future<Either<Failure, void>> approveVendor({
    required String vendorId,
    String? reason,
  });

  /// Reject a vendor application
  Future<Either<Failure, void>> rejectVendor({
    required String vendorId,
    required String reason,
  });

  /// Activate a vendor
  Future<Either<Failure, void>> activateVendor({
    required String vendorId,
    String? reason,
  });

  /// Deactivate a vendor
  Future<Either<Failure, void>> deactivateVendor({
    required String vendorId,
    required String reason,
  });

  /// Suspend a vendor
  Future<Either<Failure, void>> suspendVendor({
    required String vendorId,
    required String reason,
    DateTime? suspendUntil,
  });
}


