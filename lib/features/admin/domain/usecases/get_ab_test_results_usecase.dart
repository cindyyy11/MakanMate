import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for fetching A/B test results
class GetABTestResultsUseCase {
  final AdminRepository repository;

  GetABTestResultsUseCase(this.repository);

  Future<Either<Failure, ABTestResult>> call(String testId) async {
    return await repository.getABTestResults(testId);
  }
}


