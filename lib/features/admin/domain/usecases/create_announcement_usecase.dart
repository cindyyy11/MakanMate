import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case to create a system-wide announcement
class CreateAnnouncementUseCase {
  final AdminRepository repository;

  CreateAnnouncementUseCase(this.repository);

  Future<Either<Failure, String>> call(CreateAnnouncementParams params) async {
    return await repository.createAnnouncement(
      title: params.title,
      message: params.message,
      priority: params.priority,
      targetAudience: params.targetAudience,
      expiresAt: params.expiresAt,
    );
  }
}

class CreateAnnouncementParams {
  final String title;
  final String message;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String targetAudience; // 'all', 'users', 'vendors', 'admins'
  final DateTime? expiresAt;

  CreateAnnouncementParams({
    required this.title,
    required this.message,
    this.priority = 'medium',
    this.targetAudience = 'all',
    this.expiresAt,
  });
}


