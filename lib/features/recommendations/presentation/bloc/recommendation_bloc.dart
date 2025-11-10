import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_contextual_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_similar_items_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/track_interaction_usecase.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';

/// BLoC for managing recommendation state
/// 
/// Handles all recommendation-related business logic and state management
class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final GetRecommendationsUseCase getRecommendations;
  final GetContextualRecommendationsUseCase getContextualRecommendations;
  final GetSimilarItemsUseCase getSimilarItems;
  final TrackInteractionUseCase trackInteraction;
  final Logger logger;

  RecommendationBloc({
    required this.getRecommendations,
    required this.getContextualRecommendations,
    required this.getSimilarItems,
    required this.trackInteraction,
    required this.logger,
  }) : super(const RecommendationInitial()) {
    on<LoadRecommendationsEvent>(_onLoadRecommendations);
    on<LoadContextualRecommendationsEvent>(_onLoadContextualRecommendations);
    on<LoadSimilarItemsEvent>(_onLoadSimilarItems);
    on<RefreshRecommendationsEvent>(_onRefreshRecommendations);
    on<TrackInteractionEvent>(_onTrackInteraction);
    on<ClearRecommendationsEvent>(_onClearRecommendations);
  }

  /// Handle loading recommendations
  Future<void> _onLoadRecommendations(
    LoadRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      logger.i('Loading recommendations for user: ${event.userId}');
      emit(const RecommendationLoading());

      final result = await getRecommendations(
        GetRecommendationsParams(
          userId: event.userId,
          limit: event.limit,
          context: event.context,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load recommendations: ${failure.message}');
          emit(RecommendationError(message: failure.message));
        },
        (recommendations) {
          logger.i('Successfully loaded ${recommendations.length} recommendations');
          if (recommendations.isEmpty) {
            emit(const RecommendationEmpty());
          } else {
            emit(RecommendationLoaded(recommendations: recommendations));
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading recommendations: $e', stackTrace: stackTrace);
      emit(RecommendationError(message: 'Unexpected error: $e'));
    }
  }

  /// Handle loading contextual recommendations
  Future<void> _onLoadContextualRecommendations(
    LoadContextualRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      logger.i('Loading contextual recommendations for user: ${event.userId}');
      emit(const RecommendationLoading());

      final result = await getContextualRecommendations(
        GetContextualRecommendationsParams(
          userId: event.userId,
          context: event.context,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load contextual recommendations: ${failure.message}');
          emit(RecommendationError(message: failure.message));
        },
        (recommendations) {
          logger.i('Successfully loaded ${recommendations.length} contextual recommendations');
          if (recommendations.isEmpty) {
            emit(const RecommendationEmpty(
              message: 'No contextual recommendations available',
            ));
          } else {
            emit(RecommendationLoaded(
              recommendations: recommendations,
              source: 'contextual',
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading contextual recommendations: $e', stackTrace: stackTrace);
      emit(RecommendationError(message: 'Unexpected error: $e'));
    }
  }

  /// Handle loading similar items
  Future<void> _onLoadSimilarItems(
    LoadSimilarItemsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      logger.i('Loading similar items for: ${event.itemId}');
      emit(const RecommendationLoading());

      final result = await getSimilarItems(
        GetSimilarItemsParams(
          itemId: event.itemId,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load similar items: ${failure.message}');
          emit(RecommendationError(message: failure.message));
        },
        (similarItems) {
          logger.i('Successfully loaded ${similarItems.length} similar items');
          if (similarItems.isEmpty) {
            emit(const RecommendationEmpty(
              message: 'No similar items found',
            ));
          } else {
            emit(SimilarItemsLoaded(
              similarItems: similarItems,
              sourceItemId: event.itemId,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading similar items: $e', stackTrace: stackTrace);
      emit(RecommendationError(message: 'Unexpected error: $e'));
    }
  }

  /// Handle refreshing recommendations
  Future<void> _onRefreshRecommendations(
    RefreshRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      logger.i('Refreshing recommendations for user: ${event.userId}');

      // If we have current recommendations, show them while refreshing
      List<RecommendationEntity>? currentRecs;
      if (state is RecommendationLoaded) {
        currentRecs = (state as RecommendationLoaded).recommendations;
        emit(RecommendationRefreshing(currentRecommendations: currentRecs));
      } else {
        emit(const RecommendationLoading());
      }

      final result = await getRecommendations(
        GetRecommendationsParams(
          userId: event.userId,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to refresh recommendations: ${failure.message}');
          // If we had cached recommendations, show error with cache
          if (currentRecs != null) {
            emit(RecommendationError(
              message: 'Failed to refresh: ${failure.message}',
              cachedRecommendations: currentRecs,
            ));
          } else {
            emit(RecommendationError(message: failure.message));
          }
        },
        (recommendations) {
          logger.i('Successfully refreshed ${recommendations.length} recommendations');
          if (recommendations.isEmpty) {
            emit(const RecommendationEmpty());
          } else {
            emit(RecommendationLoaded(
              recommendations: recommendations,
              source: 'refreshed',
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error refreshing recommendations: $e', stackTrace: stackTrace);
      emit(RecommendationError(message: 'Unexpected error: $e'));
    }
  }

  /// Handle tracking interaction
  Future<void> _onTrackInteraction(
    TrackInteractionEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      logger.i('Tracking interaction: ${event.userId} -> ${event.itemId}');

      // Keep current recommendations visible
      List<RecommendationEntity>? currentRecs;
      if (state is RecommendationLoaded) {
        currentRecs = (state as RecommendationLoaded).recommendations;
      }

      final result = await trackInteraction(
        TrackInteractionParams(
          userId: event.userId,
          itemId: event.itemId,
          interactionType: event.interactionType,
          rating: event.rating,
          context: event.context,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to track interaction: ${failure.message}');
          // Don't show error to user, just log it
          // Keep current state
        },
        (_) {
          logger.i('Successfully tracked interaction');
          // Optionally emit a success state or just keep current recommendations
          if (currentRecs != null) {
            emit(InteractionTracked(
              message: 'Interaction tracked',
              recommendations: currentRecs,
            ));
            // Immediately go back to loaded state
            emit(RecommendationLoaded(recommendations: currentRecs));
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error tracking interaction: $e', stackTrace: stackTrace);
      // Don't emit error state for interaction tracking failures
    }
  }

  /// Handle clearing recommendations
  Future<void> _onClearRecommendations(
    ClearRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    logger.i('Clearing recommendations');
    emit(const RecommendationInitial());
  }
}

