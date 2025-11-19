import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
    String role = 'user',
  });
  
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  
  Future<Either<Failure, UserEntity>> signInAsGuest();
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  Stream<UserEntity?> get authStateChanges;
  
  Future<void> deleteAccount(String uid);
}