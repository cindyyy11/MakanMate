import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';

/// Use case to get a user by ID
class GetUserByIdUseCase {
  final AdminUserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.userId);
  }
}

class GetUserByIdParams {
  final String userId;

  GetUserByIdParams({required this.userId});
}


