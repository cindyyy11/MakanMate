import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for getting platform metrics
class GetPlatformMetricsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetPlatformMetricsParams({this.startDate, this.endDate});
}

/// Use case for fetching platform metrics
class GetPlatformMetricsUseCase {
  final AdminRepository repository;

  GetPlatformMetricsUseCase(this.repository);

  Future<Either<Failure, PlatformMetrics>> call(
    GetPlatformMetricsParams params,
  ) async {
    return await repository.getPlatformMetrics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
