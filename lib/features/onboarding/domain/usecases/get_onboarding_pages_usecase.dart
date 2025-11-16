import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:makan_mate/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to get onboarding pages
class GetOnboardingPagesUseCase {
  final OnboardingRepository repository;

  GetOnboardingPagesUseCase(this.repository);

  Future<Either<Failure, List<OnboardingPageEntity>>> call() async {
    return Future.value(repository.getOnboardingPages());
  }
}

