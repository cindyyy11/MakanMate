import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/data/models/recommendation_models.dart';
import 'package:makan_mate/services/food_service.dart';

class FoodItemCard extends StatefulWidget {
  final RecommendationItem recommendationItem;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onBookmark;

  const FoodItemCard({
    Key? key,
    required this.recommendationItem,
    required this.onTap,
    required this.onLike,
    required this.onBookmark,
  }) : super(key: key);

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard>
  with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  FoodItem? _foodItem;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadFoodItem();
  }

  void _loadFoodItem() async {
    try {
      final foodItem = await FoodService().getFoodItem(widget.recommendationItem.itemId);
      if (mounted) {
        setState(() {
          _foodItem = foodItem;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_foodItem == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: UIConstants.elevationMd,
              shape: RoundedRectangleBorder(
                borderRadius: UIConstants.borderRadiusLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image and AI badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildFoodImage(),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildAIBadge(),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                              onPressed: () {
                                setState(() => _isLiked = !_isLiked);
                                widget.onLike();
                              },
                              color: _isLiked ? AppColors.error : AppColors.surface,
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              onPressed: () {
                                setState(() => _isBookmarked = !_isBookmarked);
                                widget.onBookmark();
                              },
                              color: _isBookmarked ? AppColors.primary : AppColors.surface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _foodItem!.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRatingChip(),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          _foodItem!.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Tags and price
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _buildCuisineTag(),
                                  if (_foodItem!.isHalal) _buildHalalTag(),
                                  if (_foodItem!.isVegetarian) _buildVegetarianTag(),
                                  _buildSpiceLevelTag(),
                                ],
                              ),
                            ),
                            _buildPriceTag(),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // AI recommendation reason
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: UIConstants.borderRadiusSm,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                size: UIConstants.iconSizeSm,
                                color: AppColors.infoDark,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.recommendationItem.reason,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.infoDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodImage() {
    if (_foodItem!.imageUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _foodItem!.imageUrls.first,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.grey200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.grey200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: UIConstants.iconSize2Xl,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 8),
          Text(
            _foodItem!.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: UIConstants.fontSizeSm,
            color: AppColors.textOnDark,
          ),
          const SizedBox(width: 4),
          Text(
            'AI',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.overlay,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: UIConstants.iconSizeMd,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRatingChip() {
    if (_foodItem!.averageRating > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: UIConstants.borderRadiusMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: UIConstants.fontSizeMd,
              color: AppColors.ratingFilled,
            ),
            const SizedBox(width: 4),
            Text(
              _foodItem!.averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warningDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCuisineTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _foodItem!.cuisineType.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHalalTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Text(
        'HALAL',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.successDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVegetarianTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.vegan, 0.1),
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Text(
        'VEG',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.vegan,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpiceLevelTag() {
    String spiceText;
    Color spiceColor;
    
    if (_foodItem!.spiceLevel <= 0.3) {
      spiceText = 'MILD';
      spiceColor = AppColors.spiceMild;
    } else if (_foodItem!.spiceLevel <= 0.7) {
      spiceText = 'MEDIUM';
      spiceColor = AppColors.spiceMedium;
    } else {
      spiceText = 'SPICY';
      spiceColor = AppColors.spiceHot;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(spiceColor, 0.1),
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: UIConstants.fontSizeSm,
            color: spiceColor,
          ),
          const SizedBox(width: 2),
          Text(
            spiceText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: spiceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: UIConstants.borderRadiusLg,
      ),
      child: Text(
        'RM ${_foodItem!.price.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textOnDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}