import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// AI-powered recommendations section for home page
///
/// Displays personalized food recommendations using the TFLite model
class AIRecommendationsSection extends StatefulWidget {
  const AIRecommendationsSection({super.key});

  @override
  State<AIRecommendationsSection> createState() =>
      _AIRecommendationsSectionState();
}

class _AIRecommendationsSectionState extends State<AIRecommendationsSection> {
  final GetFoodItemUseCase _getFoodItemUseCase = di.sl<GetFoodItemUseCase>();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<RecommendationBloc>().add(
        LoadRecommendationsEvent(userId: user.uid, limit: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationBloc, RecommendationState>(
      builder: (context, state) {
        if (state is RecommendationLoading) {
          return _buildLoadingState();
        }

        if (state is RecommendationLoaded) {
          return _buildLoadedState(state.recommendations);
        }

        if (state is RecommendationError) {
          return _buildErrorState();
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => _buildLoadingCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<RecommendationEntity> recommendations) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return _buildRecommendationCard(recommendations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.circular(8),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Personalized just for you',
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeSm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/recommendations');
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('See All'),
            style: TextButton.styleFrom(foregroundColor: AppColors.aiPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationEntity recommendation) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<FoodItem?>(
      future: _getFoodItem(recommendation.itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildLoadingCard();
        }

        final foodItem = snapshot.data!;

        return GestureDetector(
          onTap: () {
            // Track interaction
            if (user != null) {
              context.read<RecommendationBloc>().add(
                TrackInteractionEvent(
                  userId: user.uid,
                  itemId: recommendation.itemId,
                  interactionType: 'view',
                ),
              );
            }

            // Navigate to food detail
            // Navigator.pushNamed(context, '/food-detail', arguments: foodItem);
          },
          child: Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image with AI Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: foodItem.imageUrls.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: foodItem.imageUrls.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 120,
                                color: AppColors.grey200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 120,
                                color: AppColors.grey300,
                                child: const Icon(Icons.restaurant),
                              ),
                            )
                          : Container(
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant, size: 40),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.aiGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(recommendation.score * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Food Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: UIConstants.fontSizeSm,
                              color: AppColors.ratingFilled,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              foodItem.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (foodItem.isHalal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.halal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Halal',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.halal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'RM ${foodItem.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: UIConstants.fontSizeSm,
                            fontWeight: FontWeight.bold,
                            color: AppColors.aiPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          recommendation.reason,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: UIConstants.borderRadiusLg,
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(color: AppColors.warningLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warningDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendations Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warningDark,
                  ),
                ),
                const Text(
                  'Having trouble loading AI suggestions',
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeSm,
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _loadRecommendations,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }

  /// Get food item using use case
  Future<FoodItem?> _getFoodItem(String itemId) async {
    final result = await _getFoodItemUseCase(itemId);
    return result.fold(
      (failure) => null,
      (entity) => entity.toFoodItem(),
    );
  }
}
