import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:makan_mate/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of onboarding repository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Either<Failure, List<OnboardingPageEntity>> getOnboardingPages() {
    try {
      final pages = localDataSource.getOnboardingPages();
      return Right(pages);
    } catch (e) {
      return Left(CacheFailure('Failed to get onboarding pages: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await localDataSource.completeOnboarding();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to complete onboarding: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final result = await localDataSource.hasCompletedOnboarding();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Failed to check onboarding status: $e'));
    }
  }
}

