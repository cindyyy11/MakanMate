import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to verify a user account
class VerifyUserUseCase {
  final AdminUserRepository repository;

  VerifyUserUseCase(this.repository);

  Future<Either<Failure, void>> call(VerifyUserParams params) async {
    return await repository.verifyUser(
      userId: params.userId,
      reason: params.reason,
    );
  }
}

class VerifyUserParams {
  final String userId;
  final String? reason;

  VerifyUserParams({required this.userId, this.reason});
}


