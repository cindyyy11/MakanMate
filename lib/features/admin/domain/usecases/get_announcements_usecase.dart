import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case to get active announcements
class GetAnnouncementsUseCase {
  final AdminRepository repository;

  GetAnnouncementsUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    String? targetAudience,
    bool activeOnly = true,
  }) async {
    return await repository.getAnnouncements(
      targetAudience: targetAudience,
      activeOnly: activeOnly,
    );
  }
}

