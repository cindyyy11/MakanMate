import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for pausing an A/B test
class PauseABTestUseCase {
  final AdminRepository repository;

  PauseABTestUseCase(this.repository);

  Future<Either<Failure, void>> call(String testId) async {
    return await repository.pauseABTest(testId);
  }
}


