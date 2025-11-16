import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:makan_mate/features/splash/domain/repositories/splash_repository.dart';

/// Implementation of splash repository
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  SplashRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final result = await localDataSource.hasCompletedOnboarding();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Failed to check onboarding status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setOnboardingComplete() async {
    try {
      await localDataSource.setOnboardingComplete();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to set onboarding complete: $e'));
    }
  }
}

