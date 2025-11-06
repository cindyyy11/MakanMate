import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'restaurant_card.dart';

class RecommendationSection extends StatelessWidget {
  final List<RestaurantEntity> recommendations;
  const RecommendationSection({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommended for You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recommendations.map((r) => RestaurantCard(restaurant: r)).toList(),
      ],
    );
  }
}
