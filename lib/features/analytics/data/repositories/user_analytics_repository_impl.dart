import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/analytics/data/datasources/user_analytics_remote_datasource.dart';
import 'package:makan_mate/features/analytics/domain/entities/user_analytics_entity.dart';
import 'package:makan_mate/features/analytics/domain/repositories/user_analytics_repository.dart';

class UserAnalyticsRepositoryImpl implements UserAnalyticsRepository {
  final UserAnalyticsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  UserAnalyticsRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, UserAnalytics>> getUserAnalytics() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final total = await remote.getTotalUsers();
      final verified = await remote.getVerifiedUsersCount();
      final active = await remote.getActiveUsersCount(window: Duration(days: 7));
      final usersByRole = await remote.getUsersByRole();
      final growth = await remote.getNewUsersByDay(days: 7);
      final todayLabel = _weekdayLabel(DateTime.now().weekday);
      final today = growth[todayLabel] ?? 0;
      final analytics = UserAnalytics(
        totalUsers: total,
        activeUsers: active,
        newUsersToday: today,
        verifiedUsers: verified,
        usersByRole: usersByRole,
        userGrowthWeekly: growth,
      );
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure('Failed to load analytics: $e'));
    }
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}


