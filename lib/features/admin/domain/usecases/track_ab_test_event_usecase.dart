import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for tracking A/B test event
class TrackABTestEventParams {
  final String testId;
  final String userId;
  final String eventType;
  final Map<String, dynamic>? eventData;

  const TrackABTestEventParams({
    required this.testId,
    required this.userId,
    required this.eventType,
    this.eventData,
  });
}

/// Use case for tracking an A/B test event
class TrackABTestEventUseCase {
  final AdminRepository repository;

  TrackABTestEventUseCase(this.repository);

  Future<Either<Failure, void>> call(TrackABTestEventParams params) async {
    return await repository.trackABTestEvent(
      testId: params.testId,
      userId: params.userId,
      eventType: params.eventType,
      eventData: params.eventData,
    );
  }
}


