import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to ban a user
class BanUserUseCase {
  final AdminUserRepository repository;

  BanUserUseCase(this.repository);

  Future<Either<Failure, void>> call(BanUserParams params) async {
    return await repository.banUser(
      userId: params.userId,
      reason: params.reason,
      banUntil: params.banUntil,
    );
  }
}

class BanUserParams {
  final String userId;
  final String reason;
  final DateTime? banUntil;

  BanUserParams({
    required this.userId,
    required this.reason,
    this.banUntil,
  });
}


