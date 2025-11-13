import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class CategorySection extends StatelessWidget {
  final List<RestaurantEntity> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final r = categories[i];
          final cuisineName = r.vendor.cuisine ?? "Unknown";

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(Icons.fastfood, color: Colors.orange),
                ),
                const SizedBox(height: 6),
                Text(
                  cuisineName,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
