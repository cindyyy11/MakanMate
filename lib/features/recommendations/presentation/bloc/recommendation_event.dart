import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';

/// Base event for recommendation BLoC
abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load recommendations for a user
class LoadRecommendationsEvent extends RecommendationEvent {
  final String userId;
  final int limit;
  final RecommendationContextEntity? context;

  const LoadRecommendationsEvent({
    required this.userId,
    this.limit = 10,
    this.context,
  });

  @override
  List<Object?> get props => [userId, limit, context];
}

/// Event to load contextual recommendations
class LoadContextualRecommendationsEvent extends RecommendationEvent {
  final String userId;
  final RecommendationContextEntity context;
  final int limit;

  const LoadContextualRecommendationsEvent({
    required this.userId,
    required this.context,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, context, limit];
}

/// Event to load similar items
class LoadSimilarItemsEvent extends RecommendationEvent {
  final String itemId;
  final int limit;

  const LoadSimilarItemsEvent({
    required this.itemId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [itemId, limit];
}

/// Event to refresh recommendations
class RefreshRecommendationsEvent extends RecommendationEvent {
  final String userId;
  final int limit;

  const RefreshRecommendationsEvent({
    required this.userId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Event to track user interaction
class TrackInteractionEvent extends RecommendationEvent {
  final String userId;
  final String itemId;
  final String interactionType;
  final double? rating;
  final Map<String, dynamic>? context;

  const TrackInteractionEvent({
    required this.userId,
    required this.itemId,
    required this.interactionType,
    this.rating,
    this.context,
  });

  @override
  List<Object?> get props => [userId, itemId, interactionType, rating, context];
}

/// Event to clear recommendations
class ClearRecommendationsEvent extends RecommendationEvent {
  const ClearRecommendationsEvent();
}

