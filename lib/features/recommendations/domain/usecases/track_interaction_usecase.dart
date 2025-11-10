import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/usecases/usecase.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for tracking user interactions with recommendations
/// 
/// Essential for improving recommendation quality over time
class TrackInteractionUseCase implements UseCase<void, TrackInteractionParams> {
  final RecommendationRepository repository;

  TrackInteractionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(TrackInteractionParams params) async {
    return await repository.trackInteraction(
      userId: params.userId,
      itemId: params.itemId,
      interactionType: params.interactionType,
      rating: params.rating,
      context: params.context,
    );
  }
}

/// Parameters for tracking interactions
class TrackInteractionParams extends Equatable {
  final String userId;
  final String itemId;
  final String interactionType; // view, like, order, bookmark, share
  final double? rating;
  final Map<String, dynamic>? context;

  const TrackInteractionParams({
    required this.userId,
    required this.itemId,
    required this.interactionType,
    this.rating,
    this.context,
  });

  @override
  List<Object?> get props => [userId, itemId, interactionType, rating, context];
}

