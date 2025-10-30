import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  
  SignOutUseCase(this.repository);
  
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}