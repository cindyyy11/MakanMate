import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';

/// Use case to create a new admin account
class CreateAdminUseCase {
  final AdminUserRepository repository;

  CreateAdminUseCase(this.repository);

  Future<Either<Failure, String>> call(CreateAdminParams params) async {
    return await repository.createAdmin(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class CreateAdminParams {
  final String email;
  final String password;
  final String displayName;

  CreateAdminParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}


