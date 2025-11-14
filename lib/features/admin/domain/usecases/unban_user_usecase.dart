import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to unban a user
class UnbanUserUseCase {
  final AdminUserRepository repository;

  UnbanUserUseCase(this.repository);

  Future<Either<Failure, void>> call(UnbanUserParams params) async {
    return await repository.unbanUser(
      userId: params.userId,
      reason: params.reason,
    );
  }
}

class UnbanUserParams {
  final String userId;
  final String? reason;

  UnbanUserParams({required this.userId, this.reason});
}


