import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:makan_mate/features/home/presentation/pages/restaurant_detail_page.dart';

class CategoryRestaurantPage extends StatelessWidget {
  final String categoryName;

  const CategoryRestaurantPage({Key? key, required this.categoryName})
      : super(key: key);

  Stream<double> _watchVendorRating(String vendorId) {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return 0.0;

      double total = 0;
      for (var doc in snap.docs) {
        final rating = (doc['rating'] as num?)?.toDouble() ?? 0.0;
        total += rating;
      }

      return total / snap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text('$categoryName Restaurants'),
      ),

      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeLoaded) {
            final filteredList = state.restaurants
                .where((r) =>
                    (r.vendor.cuisineType ?? '').toLowerCase() ==
                    categoryName.toLowerCase())
                .toList();

            if (filteredList.isEmpty) {
              return Center(
                child: Text(
                  'No $categoryName restaurants found.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) =>
                  _buildRestaurantCard(context, filteredList[index]),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantEntity restaurant) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vendor = restaurant.vendor;

    final imageUrl = vendor.businessLogoUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailPage(restaurant: restaurant),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: theme.dividerColor.withOpacity(0.3),
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: theme.dividerColor.withOpacity(0.3),
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      vendor.shortDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),

                        StreamBuilder<double>(
                          stream: _watchVendorRating(vendor.id),
                          builder: (context, snap) {
                            if (!snap.hasData) return Text("-", style: theme.textTheme.bodyMedium);
                            final avg = snap.data!;
                            return Text(
                              avg > 0 ? avg.toStringAsFixed(1) : "-",
                              style: theme.textTheme.bodyMedium,
                            );
                          },
                        ),

                        const Spacer(),

                        Text(
                          vendor.priceRange ?? '-',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
