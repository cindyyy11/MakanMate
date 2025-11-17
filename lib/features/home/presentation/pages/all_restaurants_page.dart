import 'package:cloud_firestore/cloud_firestore.dart';
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
        final r = (doc['rating'] as num?)?.toDouble() ?? 0.0;
        total += r;
      }

      return total / snap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "All Restaurants",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[300],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: restaurants.isEmpty
          ? const Center(
              child: Text(
                "No restaurants available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildRestaurantCard(BuildContext context, RestaurantEntity r) {
    final vendor = r.vendor;

    final String? imageUrl = vendor.businessLogoUrl;
    final rating =
        vendor.ratingAverage != null ? vendor.ratingAverage!.toStringAsFixed(1) : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              builder: (_) => RestaurantDetailPage(restaurant: r),
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
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/logos/image-not-found.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/logos/image-not-found.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      vendor.shortDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        StreamBuilder<double>(
                          stream: _watchVendorRating(vendor.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("-");
                            }

                            final avg = snapshot.data!;
                            return Text(
                              avg > 0 ? avg.toStringAsFixed(1) : "-",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        Text(
                          vendor.priceRange ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
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
