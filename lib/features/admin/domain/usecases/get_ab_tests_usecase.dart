import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for getting A/B tests
class GetABTestsParams {
  final ABTestStatus? status;
  final int? limit;

  const GetABTestsParams({this.status, this.limit});
}

/// Use case for fetching A/B tests
class GetABTestsUseCase {
  final AdminRepository repository;

  GetABTestsUseCase(this.repository);

  Future<Either<Failure, List<ABTest>>> call(GetABTestsParams params) async {
    return await repository.getABTests(
      status: params.status,
      limit: params.limit,
    );
  }
}


