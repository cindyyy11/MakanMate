import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';
import 'package:makan_mate/features/user/domain/repositories/user_repository.dart';

/// Use case for getting a user by ID
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.getUser(userId);
  }
}

