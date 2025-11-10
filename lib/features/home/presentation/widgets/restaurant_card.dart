import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;
  
  const RestaurantCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to restaurant details
        },
        borderRadius: UIConstants.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(UIConstants.radiusMd),
              ),
              child: Image.network(
                restaurant.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.grey300,
                  child: const Icon(
                    Icons.restaurant,
                    size: UIConstants.iconSize2Xl,
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: UIConstants.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: UIConstants.fontSizeXl,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: AppColors.ratingFilled,
                        size: UIConstants.iconSizeMd,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Cuisine and price
                  Text(
                    '${restaurant.cuisineType} • ${restaurant.priceRange}',
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: UIConstants.fontSizeMd,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      if (restaurant.isHalal)
                        _buildTag('Halal', AppColors.success),
                      if (restaurant.isVegetarian)
                        _buildTag('Vegetarian', AppColors.vegan),
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
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: UIConstants.fontSizeSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
