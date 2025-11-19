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
    if (user == null) return const Stream.empty();

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
      builder: (_) => AlertDialog(
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _favoritesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No favorites added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final fav = docs[index].data();
              final docId = docs[index].id;

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

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(
                        restaurant: restaurant,
                      ),
                    ),
                  );
                },

                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                              color: Theme.of(context).cardColor,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),

                                  StreamBuilder<double>(
                                    stream:
                                        _watchVendorRating(fav['id'] ?? ""),
                                    builder: (_, snap) {
                                      if (!snap.hasData ||
                                          snap.data! == 0.0) {
                                        return const Text("-");
                                      }
                                      return Text(
                                        snap.data!.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      );
                                    },
                                  ),

                                  const Spacer(),

                                  Text(
                                    fav['priceRange'] ?? '-',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).iconTheme.color,
                          onPressed: () => _confirmAndDelete(
                              context, docId, fav['name']),
                        ),
                      ],
                    ),
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
