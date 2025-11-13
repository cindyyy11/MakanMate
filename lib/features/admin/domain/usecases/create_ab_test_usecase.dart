import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for creating a new A/B test
class CreateABTestUseCase {
  final AdminRepository repository;

  CreateABTestUseCase(this.repository);

  Future<Either<Failure, ABTest>> call(ABTest test) async {
    return await repository.createABTest(test);
  }
}


