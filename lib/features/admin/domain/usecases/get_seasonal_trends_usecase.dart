import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for getting seasonal trend analysis
class GetSeasonalTrendsUseCase {
  final AdminRepository repository;

  GetSeasonalTrendsUseCase(this.repository);

  Future<Either<Failure, SeasonalTrendAnalysis>> call(
    GetSeasonalTrendsParams params,
  ) async {
    return await repository.getSeasonalTrends(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Parameters for getting seasonal trends
class GetSeasonalTrendsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  GetSeasonalTrendsParams({
    this.startDate,
    this.endDate,
  });
}


