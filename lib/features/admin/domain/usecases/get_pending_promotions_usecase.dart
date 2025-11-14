import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_promotion_management_datasource.dart';

/// Use case to get pending promotions
class GetPendingPromotionsUseCase {
  final AdminPromotionManagementDataSource dataSource;

  GetPendingPromotionsUseCase(this.dataSource);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    try {
      final promotions = await dataSource.getPendingPromotions();
      return Right(promotions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

