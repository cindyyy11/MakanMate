import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for getting activity logs
class GetActivityLogsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final int? limit;

  const GetActivityLogsParams({
    this.startDate,
    this.endDate,
    this.userId,
    this.limit,
  });
}

/// Use case for fetching activity logs
class GetActivityLogsUseCase {
  final AdminRepository repository;

  GetActivityLogsUseCase(this.repository);

  Future<Either<Failure, List<ActivityLog>>> call(
    GetActivityLogsParams params,
  ) async {
    return await repository.getActivityLogs(
      startDate: params.startDate,
      endDate: params.endDate,
      userId: params.userId,
      limit: params.limit,
    );
  }
}
