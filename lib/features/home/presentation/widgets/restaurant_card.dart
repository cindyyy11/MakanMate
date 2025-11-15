import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vendor = restaurant.vendor;

    final imageUrl =
        vendor.businessLogoUrl ?? 'assets/images/logos/image-not-found.jpg';

    final rating = vendor.ratingAverage?.toStringAsFixed(1) ?? '-';

    final hasHalal = vendor.certifications.any(
      (c) => c.type.toLowerCase() == "halal",
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/restaurantDetail',
            arguments: restaurant,
          );
        },
        borderRadius: UIConstants.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(vendor.cuisineType ?? '-'),
                  Text(vendor.priceRange ?? '-'),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating),

                      if (hasHalal)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.mosque,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                      const Icon(
                        Icons.star,
                        color: AppColors.ratingFilled,
                        size: UIConstants.iconSizeMd,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.ratingAverage?.toStringAsFixed(1) ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // cuisineType and price
                  Text(
                    '${restaurant.cuisineType ?? '-'} • ${restaurant.priceRange ?? '-'}',
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
                      // if (restaurant.isHalal)
                      //   _buildTag('Halal', AppColors.success),
                      // if (restaurant.isVegetarian)
                      //   _buildTag('Vegetarian', AppColors.vegan),
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
