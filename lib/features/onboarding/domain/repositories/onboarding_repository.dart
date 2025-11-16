import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';

/// Repository interface for onboarding operations
abstract class OnboardingRepository {
  Either<Failure, List<OnboardingPageEntity>> getOnboardingPages();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> hasCompletedOnboarding();
}

