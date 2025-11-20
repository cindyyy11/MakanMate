import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';

class SignInAsGuestUseCase {
  final AuthRepository repository;
  
  SignInAsGuestUseCase(this.repository);
  
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInAsGuest();
  }
}



