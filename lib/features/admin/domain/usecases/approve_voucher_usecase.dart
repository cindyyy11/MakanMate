import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';

/// Use case to approve a voucher
class ApproveVoucherUseCase {
  final AdminVoucherManagementDataSource dataSource;
  final NetworkInfo networkInfo;

  ApproveVoucherUseCase(this.dataSource, this.networkInfo);

  Future<Either<Failure, void>> call(ApproveVoucherParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await dataSource.approveVoucher(
        vendorId: params.vendorId,
        voucherId: params.voucherId,
        reason: params.reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ApproveVoucherParams {
  final String vendorId;
  final String voucherId;
  final String? reason;

  ApproveVoucherParams({
    required this.vendorId,
    required this.voucherId,
    this.reason,
  });
}

