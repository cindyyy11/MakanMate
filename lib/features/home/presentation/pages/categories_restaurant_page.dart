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

  /// ⭐ SAME rating stream as RestaurantDetailPage
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
        title: Text('$categoryName Restaurants'),
        backgroundColor: Colors.orange[300],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            final filteredList = state.restaurants
                .where((r) =>
                    (r.vendor.cuisineType ?? '').toLowerCase() ==
                    categoryName.toLowerCase())
                .toList();

            if (filteredList.isEmpty) {
              return Center(
                child: Text(
                  'No $categoryName restaurants found.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) =>
                  _buildRestaurantCard(context, filteredList[index]),
            );
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantEntity r) {
    final vendor = r.vendor;

    final imageUrl = vendor.businessLogoUrl;

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
              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/logos/image-not-found.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/logos/image-not-found.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      vendor.shortDescription,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    /// ⭐ LIVE RATING STREAM
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),

                        StreamBuilder<double>(
                          stream: _watchVendorRating(vendor.id),
                          builder: (context, snap) {
                            if (!snap.hasData) return const Text("-");
                            final avg = snap.data!;
                            return Text(
                              avg > 0 ? avg.toStringAsFixed(1) : "-",
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
