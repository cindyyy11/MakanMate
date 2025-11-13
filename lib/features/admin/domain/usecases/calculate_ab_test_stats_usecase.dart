import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for calculating A/B test statistics
class CalculateABTestStatsUseCase {
  final AdminRepository repository;

  CalculateABTestStatsUseCase(this.repository);

  Future<Either<Failure, ABTestResult>> call(String testId) async {
    return await repository.calculateABTestStats(testId);
  }
}


