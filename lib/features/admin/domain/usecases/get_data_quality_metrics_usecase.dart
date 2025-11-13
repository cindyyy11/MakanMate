import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/data_quality_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for fetching data quality metrics
class GetDataQualityMetricsUseCase {
  final AdminRepository repository;

  GetDataQualityMetricsUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, DataQualityMetrics>> call() async {
    return await repository.getDataQualityMetrics();
  }
}

