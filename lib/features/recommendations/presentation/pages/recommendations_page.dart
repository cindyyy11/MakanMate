import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';
import 'package:makan_mate/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:makan_mate/services/food_service.dart';

/// Page displaying personalized AI recommendations
class RecommendationsPage extends StatefulWidget {
  final String userId;

  const RecommendationsPage({
    super.key,
    required this.userId,
  });

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final FoodService _foodService = FoodService();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    context.read<RecommendationBloc>().add(
          LoadRecommendationsEvent(
            userId: widget.userId,
            limit: 20,
          ),
        );
  }

  void _refreshRecommendations() {
    context.read<RecommendationBloc>().add(
          RefreshRecommendationsEvent(
            userId: widget.userId,
            limit: 20,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.purple[300],
            ),
            const SizedBox(width: 8),
            const Text('AI Recommendations'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
            tooltip: 'Refresh recommendations',
          ),
        ],
      ),
      body: BlocBuilder<RecommendationBloc, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return _buildLoadingState();
          }

          if (state is RecommendationLoaded) {
            return _buildLoadedState(state);
          }

          if (state is RecommendationRefreshing) {
            return _buildRefreshingState(state);
          }

          if (state is RecommendationError) {
            return _buildErrorState(state);
          }

          if (state is RecommendationEmpty) {
            return _buildEmptyState(state);
          }

          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.purple[400]!,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding perfect dishes for you...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is analyzing your preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(RecommendationLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshRecommendations();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = state.recommendations[index];
          
          return FutureBuilder<FoodItem?>(
            future: _foodService.getFoodItem(recommendation.itemId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final foodItem = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendationCard(
                  recommendation: recommendation,
                  foodItem: foodItem,
                  onTap: () {
                    // Track view interaction
                    context.read<RecommendationBloc>().add(
                          TrackInteractionEvent(
                            userId: widget.userId,
                            itemId: recommendation.itemId,
                            interactionType: 'view',
                          ),
                        );
                    
                    // Navigate to food detail page
                    // Navigator.push(...)
                  },
                  onBookmark: () {
                    // Handle bookmark
                    context.read<RecommendationBloc>().add(
                          TrackInteractionEvent(
                            userId: widget.userId,
                            itemId: recommendation.itemId,
                            interactionType: 'bookmark',
                          ),
                        );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRefreshingState(RecommendationRefreshing state) {
    return Stack(
      children: [
        // Show current recommendations
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.currentRecommendations.length,
          itemBuilder: (context, index) {
            final recommendation = state.currentRecommendations[index];
            
            return FutureBuilder<FoodItem?>(
              future: _foodService.getFoodItem(recommendation.itemId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final foodItem = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Opacity(
                    opacity: 0.6,
                    child: RecommendationCard(
                      recommendation: recommendation,
                      foodItem: foodItem,
                      onTap: () {},
                    ),
                  ),
                );
              },
            );
          },
        ),
        
        // Loading overlay
        Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Refreshing recommendations...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(RecommendationError state) {
    // If we have cached recommendations, show them with error banner
    if (state.cachedRecommendations != null && 
        state.cachedRecommendations!.isNotEmpty) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange[100],
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing cached results. ${state.message}',
                    style: TextStyle(color: Colors.orange[900]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshRecommendations,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cachedRecommendations!.length,
              itemBuilder: (context, index) {
                final recommendation = state.cachedRecommendations![index];
                
                return FutureBuilder<FoodItem?>(
                  future: _foodService.getFoodItem(recommendation.itemId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecommendationCard(
                        recommendation: recommendation,
                        foodItem: snapshot.data!,
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // Show error state
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecommendations,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(RecommendationEmpty state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Recommendations Yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRecommendations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.purple[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'AI-Powered Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap below to get personalized food suggestions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRecommendations,
            icon: const Icon(Icons.stars),
            label: const Text('Get Recommendations'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

