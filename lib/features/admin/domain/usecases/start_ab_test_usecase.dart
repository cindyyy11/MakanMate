import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for starting an A/B test
class StartABTestUseCase {
  final AdminRepository repository;

  StartABTestUseCase(this.repository);

  Future<Either<Failure, void>> call(String testId) async {
    return await repository.startABTest(testId);
  }
}


