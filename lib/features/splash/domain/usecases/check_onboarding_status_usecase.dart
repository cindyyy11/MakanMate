import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/splash/domain/repositories/splash_repository.dart';

/// Use case to check if user has completed onboarding
class CheckOnboardingStatusUseCase {
  final SplashRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.hasCompletedOnboarding();
  }
}

