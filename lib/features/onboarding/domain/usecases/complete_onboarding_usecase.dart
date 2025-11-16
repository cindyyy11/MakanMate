import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to complete onboarding
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.completeOnboarding();
  }
}

