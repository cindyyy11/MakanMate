import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';

/// Repository interface for splash screen operations
abstract class SplashRepository {
  Future<Either<Failure, bool>> hasCompletedOnboarding();
  Future<Either<Failure, void>> setOnboardingComplete();
}

