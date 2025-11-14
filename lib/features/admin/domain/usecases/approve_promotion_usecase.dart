import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_promotion_management_datasource.dart';

/// Use case to approve a promotion
class ApprovePromotionUseCase {
  final AdminPromotionManagementDataSource dataSource;

  ApprovePromotionUseCase(this.dataSource);

  Future<Either<Failure, void>> call(ApprovePromotionParams params) async {
    try {
      await dataSource.approvePromotion(
        approvalDocId: params.approvalDocId,
        vendorId: params.vendorId,
        promotionId: params.promotionId,
        reason: params.reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ApprovePromotionParams {
  final String approvalDocId;
  final String vendorId;
  final String promotionId;
  final String? reason;

  ApprovePromotionParams({
    required this.approvalDocId,
    required this.vendorId,
    required this.promotionId,
    this.reason,
  });
}

