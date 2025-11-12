import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_application_entity.dart';

/// Repository interface for vendor applications (Domain layer)
abstract class VendorRepository {
  /// Create vendor application
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
  });

  /// Get vendor application by ID
  Future<Either<Failure, VendorApplicationEntity>> getVendorApplication(
    String applicationId,
  );

  /// Get vendor application by user ID
  Future<Either<Failure, VendorApplicationEntity?>> getVendorApplicationByUserId(
    String userId,
  );

  /// Approve vendor application (admin operation)
  Future<Either<Failure, void>> approveVendorApplication({
    required String applicationId,
    required String userId,
  });

  /// Reject vendor application (admin operation)
  Future<Either<Failure, void>> rejectVendorApplication({
    required String applicationId,
    required String reason,
  });
}

