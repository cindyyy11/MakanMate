import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/analytics/domain/entities/user_analytics_entity.dart';
import 'package:makan_mate/features/analytics/domain/repositories/user_analytics_repository.dart';

class GetUserAnalyticsUseCase {
  final UserAnalyticsRepository repository;
  GetUserAnalyticsUseCase(this.repository);

  Future<Either<Failure, UserAnalytics>> call() {
    return repository.getUserAnalytics();
  }
}







