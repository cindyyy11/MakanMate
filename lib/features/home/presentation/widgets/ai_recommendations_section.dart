import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
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
        print('🤖 AI Section State: ${state.runtimeType}');

        if (state is RecommendationLoading) {
          print('🤖 AI Section: Loading...');
          return _buildLoadingState();
        }

        if (state is RecommendationLoaded) {
          print(
            '🤖 AI Section: Loaded ${state.recommendations.length} recommendations',
          );
          return _buildLoadedState(state.recommendations);
        }

        if (state is RecommendationEmpty) {
          print('🤖 AI Section: Empty - ${state.message}');
          return _buildNoRecommendationsState();
        }

        if (state is RecommendationError) {
          print('🤖 AI Section: Error - ${state.message}');
          return _buildErrorState();
        }

        print('🤖 AI Section: Initial state');
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
      return _buildNoRecommendationsState();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Personalized just for you',
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeSm,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/recommendations');
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('See All'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.aiPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
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
            width: 200,
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
              mainAxisSize: MainAxisSize.min,
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
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 140,
                                width: double.infinity,
                                color: AppColors.grey200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 140,
                                width: double.infinity,
                                color: AppColors.grey300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.restaurant, size: 40),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        foodItem.name,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 140,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.restaurant, size: 40),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      foodItem.name,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Restaurant name with icon
                        FutureBuilder<String>(
                          future: _getRestaurantName(foodItem.restaurantId),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 12,
                                  color: AppColors.grey600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    snapshot.data ?? 'Loading...',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
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
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'RM ${foodItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.aiPrimary,
                            ),
                          ),
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

  Future<String> _getRestaurantName(String restaurantId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(restaurantId)
          .get();

      if (doc.exists) {
        return doc.data()?['businessName'] ??
            doc.data()?['name'] ??
            'Unknown Restaurant';
      }
      return 'Unknown Restaurant';
    } catch (e) {
      return 'Unknown Restaurant';
    }
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
    // Show loading state initially
    return _buildLoadingState();
  }

  Widget _buildNoRecommendationsState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No AI Recommendations Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring food to get personalized recommendations!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadRecommendations,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aiPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Get food item using use case
  Future<FoodItem?> _getFoodItem(String itemId) async {
    final result = await _getFoodItemUseCase(itemId);
    return result.fold((failure) => null, (entity) => entity.toFoodItem());
  }
}
