import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/pages/restaurant_detail_page.dart';

class AllRestaurantsPage extends StatelessWidget {
  final List<RestaurantEntity> restaurants;

  const AllRestaurantsPage({Key? key, required this.restaurants})
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("All Restaurants"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),

      body: restaurants.isEmpty
          ? Center(
              child: Text(
                "No restaurants available.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: restaurants.length,
              itemBuilder: (context, index) =>
                  _buildRestaurantCard(context, restaurants[index]),
            ),
    );
  }

  Widget _buildFavoriteButton(RestaurantEntity restaurant) {
    final vendor = restaurant.vendor;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favorites')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('items')
          .doc(vendor.id)
          .snapshots(),
      builder: (context, snapshot) {
        final isFavorited = snapshot.data?.exists ?? false;

        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
          ),
          color: isFavorited ? Colors.red : Colors.grey,
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please log in first.")),
              );
              return;
            }

            final ref = FirebaseFirestore.instance
                .collection('favorites')
                .doc(user.uid)
                .collection('items')
                .doc(vendor.id);

            if (isFavorited) {
              await ref.delete();
            } else {
              await ref.set({
                'id': vendor.id,
                'name': vendor.businessName,
                'cuisineType': vendor.cuisineType,
                'rating': vendor.ratingAverage,
                'priceRange': vendor.priceRange,
                'image': vendor.businessLogoUrl,
                'description': vendor.shortDescription,
              });
            }
          },
        );
      },
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantEntity r) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vendor = r.vendor;
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
          ),
        ],
      ),

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailPage(restaurant: r),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              /// IMAGE
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

              /// DETAILS
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
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
                            if (!snap.hasData) {
                              return Text(
                                "-",
                                style: theme.textTheme.bodyMedium,
                              );
                            }
                            final avg = snap.data!;
                            return Text(
                              avg > 0 ? avg.toStringAsFixed(1) : "-",
                              style: theme.textTheme.bodyMedium,
                            );
                          },
                        ),

                        const Spacer(),

                        Text(
                          vendor.priceRange ?? "-",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(width: 4),

                        _buildFavoriteButton(r),
                      ],
                    ),
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
