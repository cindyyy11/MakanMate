import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

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

  Stream<QuerySnapshot<Map<String, dynamic>>> _favoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .snapshots();
  }

  Future<void> _confirmAndDelete(
      BuildContext context, String docId, String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Remove $name from favorites?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .collection('items')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.orange[300],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No favorites added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final fav = docs[index].data();
              final docId = docs[index].id;

              return GestureDetector(
                onTap: () {
                  final vendor = VendorProfileEntity(
                    id: fav['id'] ?? '',
                    businessName: fav['name'] ?? '',
                    cuisineType: fav['cuisineType'],
                    businessAddress: '',
                    contactNumber: '',
                    emailAddress: '',
                    shortDescription: fav['description'] ?? '',
                    businessLogoUrl: fav['image'],
                    bannerImageUrl: null,
                    profilePhotoUrl: null,
                    priceRange: fav['priceRange'],
                    ratingAverage: null,
                    approvalStatus: 'verified',
                    operatingHours: const {},
                    outlets: const [],
                    certifications: const [],
                    menuItems: const [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  final restaurant = RestaurantEntity(
                    vendor: vendor,
                    menuItems: const [],
                    cuisineType: fav['cuisineType'],
                    priceRange: fav['priceRange'],
                    ratingAverage: null,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(
                        restaurant: restaurant,
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fav['image'] ?? "",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fav['name'] ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),

                                StreamBuilder<double>(
                                  stream: _watchVendorRating(fav['id']),
                                  builder: (context, snap) {
                                    if (!snap.hasData) {
                                      return const Text("-");
                                    }

                                    final avg = snap.data!;
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
                                  fav['priceRange'] ?? '-',
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

                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        onPressed: () =>
                            _confirmAndDelete(context, docId, fav['name']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
