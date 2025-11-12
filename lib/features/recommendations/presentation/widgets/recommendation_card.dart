import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';

/// Card widget to display a recommendation
///
/// Shows food item with AI-generated reason
class RecommendationCard extends StatelessWidget {
  final RecommendationEntity recommendation;
  final FoodItem foodItem;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.foodItem,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: UIConstants.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: UIConstants.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: foodItem.imageUrls.isNotEmpty
                        ? foodItem.imageUrls.first
                        : '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppColors.grey300,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppColors.grey300,
                      child: const Icon(Icons.restaurant, size: 60),
                    ),
                  ),
                ),

                // AI Badge
                Positioned(
                  top: UIConstants.spacingMd,
                  left: UIConstants.spacingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.aiGradient,
                      borderRadius: UIConstants.borderRadiusCircular,
                      boxShadow: AppColors.aiShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          size: UIConstants.iconSizeSm,
                          color: AppColors.textOnDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI Pick',
                          style: const TextStyle(
                            color: AppColors.textOnDark,
                            fontSize: UIConstants.fontSizeSm,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Confidence score
                Positioned(
                  top: UIConstants.spacingMd,
                  right: UIConstants.spacingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(recommendation.confidence),
                      borderRadius: UIConstants.borderRadiusMd,
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Text(
                      '${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: UIConstants.fontSizeSm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Bookmark button
                if (onBookmark != null)
                  Positioned(
                    bottom: UIConstants.spacingMd,
                    right: UIConstants.spacingMd,
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: UIConstants.borderRadiusCircular,
                      elevation: UIConstants.elevationMd,
                      child: InkWell(
                        onTap: onBookmark,
                        borderRadius: UIConstants.borderRadiusCircular,
                        child: Padding(
                          padding: UIConstants.paddingSm,
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? AppColors.warning
                                : AppColors.grey700,
                            size: UIConstants.iconSizeLg,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RM ${foodItem.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating and cuisine
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: UIConstants.iconSizeMd,
                        color: AppColors.ratingFilled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        foodItem.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: UIConstants.fontSizeMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${foodItem.totalRatings})',
                        style: const TextStyle(
                          fontSize: UIConstants.fontSizeSm,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: UIConstants.borderRadiusMd,
                        ),
                        child: Text(
                          foodItem.cuisineType,
                          style: const TextStyle(
                            fontSize: UIConstants.fontSizeSm,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // AI Reason with icon
                  Container(
                    padding: UIConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: UIConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.info, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: UIConstants.iconSizeMd,
                          color: AppColors.infoDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation.reason,
                            style: const TextStyle(
                              fontSize: UIConstants.fontSizeSm + 1,
                              color: AppColors.infoDark,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tags
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (foodItem.isHalal)
                        _buildTag('Halal', AppColors.success),
                      if (foodItem.isVegetarian)
                        _buildTag('Vegetarian', AppColors.vegan),
                      if (foodItem.spiceLevel > 0.5)
                        _buildTag('Spicy', AppColors.spiceHot),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(color, 0.1),
        borderRadius: UIConstants.borderRadiusSm,
        border: Border.all(color: AppColors.withOpacity(color, 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.grey500;
  }
}
