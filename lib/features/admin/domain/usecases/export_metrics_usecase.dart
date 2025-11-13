import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for exporting metrics
class ExportMetricsParams {
  final String format; // 'csv' or 'pdf'
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportMetricsParams({
    required this.format,
    this.startDate,
    this.endDate,
  });
}

/// Use case for exporting metrics
class ExportMetricsUseCase {
  final AdminRepository repository;

  ExportMetricsUseCase(this.repository);

  Future<Either<Failure, String>> call(ExportMetricsParams params) async {
    if (params.format.toLowerCase() == 'csv') {
      return await repository.exportMetricsToCSV(
        startDate: params.startDate,
        endDate: params.endDate,
      );
    } else if (params.format.toLowerCase() == 'pdf') {
      return await repository.exportMetricsToPDF(
        startDate: params.startDate,
        endDate: params.endDate,
      );
    } else {
      return const Left(ServerFailure('Unsupported export format'));
    }
  }
}
