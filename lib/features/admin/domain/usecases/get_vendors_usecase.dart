import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

/// Use case to get vendors
class GetVendorsUseCase {
  final AdminVendorRepository repository;

  GetVendorsUseCase(this.repository);

  Future<Either<Failure, List<VendorProfileEntity>>> call(
    GetVendorsParams params,
  ) async {
    return await repository.getVendors(
      approvalStatus: params.approvalStatus,
      limit: params.limit,
    );
  }
}

class GetVendorsParams {
  final String? approvalStatus;
  final int? limit;

  GetVendorsParams({this.approvalStatus, this.limit});
}
