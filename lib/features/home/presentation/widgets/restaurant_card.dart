import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant; 

  const RestaurantCard({
    super.key,
    required this.restaurant, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/restaurantDetail', arguments: restaurant);
        },
        child: Row(
          children: [
            Image.network(
              restaurant.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(restaurant.cuisine),
                  Text(restaurant.priceRange),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(restaurant.rating.toString()),
                      if (restaurant.halal)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.mosque, size: 16, color: Colors.green),
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
