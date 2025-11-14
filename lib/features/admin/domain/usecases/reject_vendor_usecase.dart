import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';

/// Use case to reject a vendor
class RejectVendorUseCase {
  final AdminVendorRepository repository;

  RejectVendorUseCase(this.repository);

  Future<Either<Failure, void>> call(RejectVendorParams params) async {
    return await repository.rejectVendor(
      vendorId: params.vendorId,
      reason: params.reason,
    );
  }
}

class RejectVendorParams {
  final String vendorId;
  final String reason;

  RejectVendorParams({required this.vendorId, required this.reason});
}
