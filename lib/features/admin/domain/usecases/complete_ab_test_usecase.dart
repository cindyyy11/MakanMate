import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for completing an A/B test
class CompleteABTestUseCase {
  final AdminRepository repository;

  CompleteABTestUseCase(this.repository);

  Future<Either<Failure, void>> call(String testId) async {
    return await repository.completeABTest(testId);
  }
}


