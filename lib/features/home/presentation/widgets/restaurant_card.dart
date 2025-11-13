import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final vendor = restaurant.vendor;

    final imageUrl = vendor.businessLogoUrl ??
        'assets/images/logos/image-not-found.jpg';

    final rating = vendor.ratingAverage?.toStringAsFixed(1) ?? '-';

    final hasHalal = vendor.certifications
        .any((c) => c.type.toLowerCase() == "halal");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/restaurantDetail',
              arguments: restaurant);
        },
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.businessName,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),

                  Text(vendor.cuisine ?? '-'),
                  Text(vendor.priceRange ?? '-'),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating),

                      if (hasHalal)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.mosque,
                              size: 16, color: Colors.green),
                        ),
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
}
