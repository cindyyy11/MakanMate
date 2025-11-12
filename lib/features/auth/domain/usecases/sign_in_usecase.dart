import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  
  SignInUseCase(this.repository);
  
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }
}