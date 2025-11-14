import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';

/// Use case to reject a voucher
class RejectVoucherUseCase {
  final AdminVoucherManagementDataSource dataSource;
  final NetworkInfo networkInfo;

  RejectVoucherUseCase(this.dataSource, this.networkInfo);

  Future<Either<Failure, void>> call(RejectVoucherParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await dataSource.rejectVoucher(
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

class RejectVoucherParams {
  final String vendorId;
  final String voucherId;
  final String reason;

  RejectVoucherParams({
    required this.vendorId,
    required this.voucherId,
    required this.reason,
  });
}

