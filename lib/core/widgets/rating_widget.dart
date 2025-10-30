import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRatingText;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.showRatingText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          maxRating,
          (index) {
            final isActive = index < rating.floor();
            final isHalf = index == rating.floor() && rating % 1 != 0;

            return Icon(
              isHalf
                  ? Icons.star_half
                  : isActive
                      ? Icons.star
                      : Icons.star_border,
              size: size,
              color: isActive || isHalf
                  ? (activeColor ?? Colors.amber)
                  : (inactiveColor ?? Colors.grey[400]),
            );
          },
        ),
        if (showRatingText) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
