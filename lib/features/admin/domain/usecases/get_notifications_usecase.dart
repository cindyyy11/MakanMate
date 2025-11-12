import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for getting notifications
class GetNotificationsParams {
  final bool? unreadOnly;
  final int? limit;

  const GetNotificationsParams({
    this.unreadOnly,
    this.limit,
  });
}

/// Use case for fetching admin notifications
class GetNotificationsUseCase {
  final AdminRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<AdminNotification>>> call(GetNotificationsParams params) async {
    return await repository.getNotifications(
      unreadOnly: params.unreadOnly,
      limit: params.limit,
    );
  }
}

