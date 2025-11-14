import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to delete user data (PDPA compliance)
class DeleteUserDataUseCase {
  final AdminUserRepository repository;

  DeleteUserDataUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteUserDataParams params) async {
    return await repository.deleteUserData(
      userId: params.userId,
      reason: params.reason,
    );
  }
}

class DeleteUserDataParams {
  final String userId;
  final String reason;

  DeleteUserDataParams({required this.userId, required this.reason});
}


