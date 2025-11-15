import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view profile.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),

          Center(
            child: Text(
              "My profile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: user.photoURL == null
                    ? const Text(
                        "Profile Photo",
                        style: TextStyle(color: Colors.grey),
                      )
                    : null,
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                child: const Text("Edit profile"),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            user.email ?? "-",
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 20),

          Text(
            user.displayName ?? "Name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              _tabButton("Favorites", 0),
              _tabButton("Reviews", 1),
            ],
          ),

          const SizedBox(height: 20),

          if (selectedTab == 0)
            _favoritesGrid(user.uid)
          else
            _reviewsPlaceholder(),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    bool active = index == selectedTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.grey[400] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _favoritesGrid(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text("No favorites yet."),
            ),
          );
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _favoriteCardFromFavorites(data);
          }).toList(),
        );
      },
    );
  }

  Widget _favoriteCardFromFavorites(Map<String, dynamic> data) {
    final vendorId = data['id'] ?? "";
    final name = data['name'] ?? "Unknown";
    final image = data['image'] ?? "";
    final priceRange = data['priceRange'] ?? "";
    final cuisineType = data['cuisineType'] ?? "";
    final ratingValue = (data['rating'] as num?)?.toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/restaurantDetail',
            arguments: {
              'vendorId': vendorId,
              'name': name,
              'image': image,
              'priceRange': priceRange,
              'cuisineType': cuisineType,
              'rating': ratingValue,
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6EDE6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: Image.network(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 14,
                          color: Colors.brown,
                        ),
                        if (cuisineType.toString().isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            cuisineType,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ratingValue != null
                                ? ratingValue.toStringAsFixed(1)
                                : "-",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 13,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewsPlaceholder() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text("Reviews tab coming soon."),
      ),
    );
  }
}
