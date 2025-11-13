import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for assigning user to variant
class AssignUserToVariantParams {
  final String testId;
  final String userId;

  const AssignUserToVariantParams({
    required this.testId,
    required this.userId,
  });
}

/// Use case for assigning a user to a variant
class AssignUserToVariantUseCase {
  final AdminRepository repository;

  AssignUserToVariantUseCase(this.repository);

  Future<Either<Failure, ABTestAssignment>> call(
    AssignUserToVariantParams params,
  ) async {
    return await repository.assignUserToVariant(
      testId: params.testId,
      userId: params.userId,
    );
  }
}


