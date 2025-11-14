import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';

/// Use case to get users
class GetUsersUseCase {
  final AdminUserRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(GetUsersParams params) async {
    return await repository.getUsers(
      role: params.role,
      isVerified: params.isVerified,
      limit: params.limit,
    );
  }
}

class GetUsersParams {
  final String? role;
  final bool? isVerified;
  final int? limit;

  GetUsersParams({this.role, this.isVerified, this.limit});
}


