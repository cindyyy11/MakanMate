import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey300,
      highlightColor: AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? UIConstants.borderRadiusSm,
        ),
      ),
    );
  }
}

class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(UIConstants.radiusMd),
            ),
          ),
          Padding(
            padding: UIConstants.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 200, height: 20),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 150, height: 16),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    ShimmerLoading(width: 60, height: 24),
                    SizedBox(width: 8),
                    ShimmerLoading(width: 80, height: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
