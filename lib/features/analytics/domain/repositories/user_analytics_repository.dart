import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/analytics/domain/entities/user_analytics_entity.dart';

abstract class UserAnalyticsRepository {
  Future<Either<Failure, UserAnalytics>> getUserAnalytics();
}


