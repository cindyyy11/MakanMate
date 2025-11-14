import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to warn a user
class WarnUserUseCase {
  final AdminUserRepository repository;

  WarnUserUseCase(this.repository);

  Future<Either<Failure, void>> call(WarnUserParams params) async {
    return await repository.warnUser(
      userId: params.userId,
      reason: params.reason,
    );
  }
}

class WarnUserParams {
  final String userId;
  final String reason;

  WarnUserParams({required this.userId, required this.reason});
}


