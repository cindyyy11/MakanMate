import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to get user violation history
class GetUserViolationHistoryUseCase {
  final AdminUserRepository repository;

  GetUserViolationHistoryUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetUserViolationHistoryParams params,
  ) async {
    return await repository.getUserViolationHistory(params.userId);
  }
}

class GetUserViolationHistoryParams {
  final String userId;

  GetUserViolationHistoryParams({required this.userId});
}


