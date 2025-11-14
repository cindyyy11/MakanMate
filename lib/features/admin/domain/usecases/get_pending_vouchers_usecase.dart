import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';

/// Use case to get pending vouchers (promotions)
class GetPendingVouchersUseCase {
  final AdminVoucherManagementDataSource dataSource;
  final NetworkInfo networkInfo;

  GetPendingVouchersUseCase(this.dataSource, this.networkInfo);

  Future<Either<Failure, List<PromotionWithVendorInfo>>> call() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final vouchers = await dataSource.getPendingVouchers();
      return Right(vouchers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

