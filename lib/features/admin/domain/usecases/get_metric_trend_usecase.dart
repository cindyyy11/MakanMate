import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for getting metric trend
class GetMetricTrendParams {
  final String metricName;
  final int days;

  const GetMetricTrendParams({
    required this.metricName,
    required this.days,
  });
}

/// Use case for fetching metric trend data
class GetMetricTrendUseCase {
  final AdminRepository repository;

  GetMetricTrendUseCase(this.repository);

  Future<Either<Failure, MetricTrend>> call(GetMetricTrendParams params) async {
    return await repository.getMetricTrend(
      metricName: params.metricName,
      days: params.days,
    );
  }
}

