import 'package:flutter/material.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';

class SearchResultRestaurantCard extends StatelessWidget {
  final SearchResultRestaurantEntity restaurant;
  final VoidCallback? onTap;

  const SearchResultRestaurantCard({
    Key? key,
    required this.restaurant,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: restaurant.businessLogoUrl != null
                  ? Image.network(
                      restaurant.businessLogoUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.storefront),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.businessName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (restaurant.cuisineType != null &&
                        restaurant.cuisineType!.isNotEmpty)
                      Text(
                        restaurant.cuisineType!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (restaurant.ratingAverage != null)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.ratingAverage!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        const SizedBox(width: 12),
                        if (restaurant.priceRange != null &&
                            restaurant.priceRange!.isNotEmpty)
                          Text(
                            restaurant.priceRange!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
