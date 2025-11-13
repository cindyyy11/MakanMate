import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';

/// Base state for recommendation BLoC
abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RecommendationInitial extends RecommendationState {
  const RecommendationInitial();
}

/// Loading state
class RecommendationLoading extends RecommendationState {
  const RecommendationLoading();
}

/// Loaded state with recommendations
class RecommendationLoaded extends RecommendationState {
  final List<RecommendationEntity> recommendations;
  final String source; // 'cache' or 'remote'

  const RecommendationLoaded({
    required this.recommendations,
    this.source = 'remote',
  });

  @override
  List<Object?> get props => [recommendations, source];

  RecommendationLoaded copyWith({
    List<RecommendationEntity>? recommendations,
    String? source,
  }) {
    return RecommendationLoaded(
      recommendations: recommendations ?? this.recommendations,
      source: source ?? this.source,
    );
  }
}

/// Similar items loaded state
class SimilarItemsLoaded extends RecommendationState {
  final List<RecommendationEntity> similarItems;
  final String sourceItemId;

  const SimilarItemsLoaded({
    required this.similarItems,
    required this.sourceItemId,
  });

  @override
  List<Object?> get props => [similarItems, sourceItemId];
}

/// Refreshing state (shows recommendations while loading new ones)
class RecommendationRefreshing extends RecommendationState {
  final List<RecommendationEntity> currentRecommendations;

  const RecommendationRefreshing({
    required this.currentRecommendations,
  });

  @override
  List<Object?> get props => [currentRecommendations];
}

/// Error state
class RecommendationError extends RecommendationState {
  final String message;
  final List<RecommendationEntity>? cachedRecommendations;

  const RecommendationError({
    required this.message,
    this.cachedRecommendations,
  });

  @override
  List<Object?> get props => [message, cachedRecommendations];
}

/// Interaction tracked state
class InteractionTracked extends RecommendationState {
  final String message;
  final List<RecommendationEntity> recommendations;

  const InteractionTracked({
    required this.message,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [message, recommendations];
}

/// Empty state (no recommendations available)
class RecommendationEmpty extends RecommendationState {
  final String message;

  const RecommendationEmpty({
    this.message = 'No recommendations available',
  });

  @override
  List<Object?> get props => [message];
}

