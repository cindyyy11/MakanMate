import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    String? displayName,
    String role = 'user',
  }) async {
    return await repository.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }
}
