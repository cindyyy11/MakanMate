import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';
import 'package:makan_mate/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:makan_mate/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';

/// Reusable widget for displaying AI recommendations
/// 
/// Can be integrated into any page (home, profile, etc.)
class RecommendationSectionWidget extends StatelessWidget {
  final String userId;
  final int displayLimit;
  final bool showHeader;
  final bool horizontal;

  const RecommendationSectionWidget({
    super.key,
    required this.userId,
    this.displayLimit = 5,
    this.showHeader = true,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) _buildHeader(context),
        _buildRecommendations(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Recommendations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personalized just for you',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<RecommendationBloc>(),
                    child: RecommendationsPage(userId: userId),
                  ),
                ),
              );
            },
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return BlocBuilder<RecommendationBloc, RecommendationState>(
      builder: (context, state) {
        if (state is RecommendationLoading) {
          return _buildLoadingState();
        }

        if (state is RecommendationLoaded) {
          return _buildLoadedState(context, state);
        }

        if (state is RecommendationError) {
          return _buildErrorState(context);
        }

        if (state is RecommendationEmpty) {
          return _buildEmptyState(context);
        }

        // Initial state - auto-load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<RecommendationBloc>().add(
                LoadRecommendationsEvent(
                  userId: userId,
                  limit: displayLimit * 2,
                ),
              );
        });

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: horizontal ? 350 : null,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.purple.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Finding perfect dishes...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, RecommendationLoaded state) {
    final recommendations = state.recommendations.take(displayLimit).toList();

    if (horizontal) {
      return SizedBox(
        height: 400,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];

            return Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              child: FutureBuilder<FoodItem?>(
                future: _getFoodItem(recommendation.itemId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Card(
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return RecommendationCard(
                    recommendation: recommendation,
                    foodItem: snapshot.data!,
                    onTap: () {
                      _handleItemTap(context, recommendation);
                    },
                    onBookmark: () {
                      _handleBookmark(context, recommendation);
                    },
                  );
                },
              ),
            );
          },
        ),
      );
    }

    // Vertical layout
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];

        return FutureBuilder<FoodItem?>(
          future: _getFoodItem(recommendation.itemId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RecommendationCard(
                recommendation: recommendation,
                foodItem: snapshot.data!,
                onTap: () {
                  _handleItemTap(context, recommendation);
                },
                onBookmark: () {
                  _handleBookmark(context, recommendation);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RecommendationBloc>().add(
                    RefreshRecommendationsEvent(
                      userId: userId,
                      limit: displayLimit * 2,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore more dishes to get personalized suggestions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(
    BuildContext context,
    dynamic recommendation,
  ) {
    // Track view interaction
    context.read<RecommendationBloc>().add(
          TrackInteractionEvent(
            userId: userId,
            itemId: recommendation.itemId,
            interactionType: 'view',
          ),
        );

    // Navigate to food detail page
    // TODO: Implement navigation to food detail page
    // Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailPage(...)));
  }

  void _handleBookmark(
    BuildContext context,
    dynamic recommendation,
  ) {
    // Track bookmark interaction
    context.read<RecommendationBloc>().add(
          TrackInteractionEvent(
            userId: userId,
            itemId: recommendation.itemId,
            interactionType: 'bookmark',
          ),
        );

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to bookmarks'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Get food item using use case
  Future<FoodItem?> _getFoodItem(String itemId) async {
    final getFoodItemUseCase = di.sl<GetFoodItemUseCase>();
    final result = await getFoodItemUseCase(itemId);
    return result.fold(
      (failure) => null,
      (entity) => entity.toFoodItem(),
    );
  }
}

