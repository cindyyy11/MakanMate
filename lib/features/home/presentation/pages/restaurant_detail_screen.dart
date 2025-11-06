import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantEntity restaurant =
        ModalRoute.of(context)!.settings.arguments as RestaurantEntity;

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(restaurant.image, height: 200, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(restaurant.location, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Cuisine: ${restaurant.cuisine}"),
            Text("Price: ${restaurant.priceRange}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(restaurant.rating.toString()),
                if (restaurant.halal)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text("Halal", style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(restaurant.description),
          ],
        ),
      ),
    );
  }
}
