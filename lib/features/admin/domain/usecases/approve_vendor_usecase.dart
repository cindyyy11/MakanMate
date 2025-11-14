import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';

/// Use case to approve a vendor
class ApproveVendorUseCase {
  final AdminVendorRepository repository;

  ApproveVendorUseCase(this.repository);

  Future<Either<Failure, void>> call(ApproveVendorParams params) async {
    return await repository.approveVendor(
      vendorId: params.vendorId,
      reason: params.reason,
    );
  }
}

class ApproveVendorParams {
  final String vendorId;
  final String? reason;

  ApproveVendorParams({required this.vendorId, this.reason});
}
