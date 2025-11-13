import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for getting fairness metrics
class GetFairnessMetricsUseCase {
  final AdminRepository repository;

  GetFairnessMetricsUseCase(this.repository);

  Future<Either<Failure, FairnessMetrics>> call(
    GetFairnessMetricsParams params,
  ) async {
    return await repository.getFairnessMetrics(
      recommendationLimit: params.recommendationLimit,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Parameters for getting fairness metrics
class GetFairnessMetricsParams {
  final int recommendationLimit;
  final DateTime? startDate;
  final DateTime? endDate;

  GetFairnessMetricsParams({
    this.recommendationLimit = 1000,
    this.startDate,
    this.endDate,
  });
}


