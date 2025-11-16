import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/pages/all_restaurants_page.dart';
import 'package:makan_mate/features/home/presentation/pages/categories_restaurant_page.dart';
import 'package:makan_mate/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
import 'package:makan_mate/features/map/presentation/pages/map_page.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_event.dart' as map;
import 'package:makan_mate/features/search/presentation/pages/search_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return _buildBody(
              categories: state.categories,
              recommendations: state.recommendations,
            );
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          const Text(
            'MakanMate',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required List<RestaurantEntity> categories,
    required List<RestaurantEntity> recommendations,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              const Text(
                'Nearby Restaurants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildMapSection(),
              const SizedBox(height: 24),
              _buildCategoriesSection(categories),
              const SizedBox(height: 24),
              _buildRecommendationsSection(recommendations),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hello, Foodie! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover amazing local food around you',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const Icon(Icons.restaurant, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/search');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 12),
            Text("Search for food, restaurants...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: BlocProvider.value(
        value: context.read<MapBloc>()..add(map.LoadMapEvent()),
        child: const MapPage(),
      ),
    );
  }

  Widget _buildCategoriesSection(List<RestaurantEntity> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final restaurant = categories[index];
              final cuisineType = restaurant.vendor.cuisineType ?? "Unknown";

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<HomeBloc>(),
                          child: CategoryRestaurantPage(categoryName: cuisineType),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cuisineType,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(List<RestaurantEntity> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended for You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllRestaurantsPage(restaurants: recommendations),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length > 5 ? 5 : recommendations.length,
          itemBuilder: (context, index) {
            final food = recommendations[index];
            return _buildFoodCard(food);
          },
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(RestaurantEntity food) {
    final vendor = food.vendor;

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
            color: isFavorited ? Colors.red : Colors.grey,
          ),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please log in to add favorites.'),
                ),
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

  Widget _buildFoodCard(RestaurantEntity food) {
    final vendor = food.vendor;

    final image = vendor.businessLogoUrl?.isNotEmpty == true
        ? vendor.businessLogoUrl!
        : 'assets/images/logos/image-not-found.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailPage(restaurant: food),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
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
                      vendor.businessName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      vendor.shortDescription,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),

                        StreamBuilder<double>(
                          stream: _watchVendorRating(vendor.id),
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
                          vendor.priceRange ?? "-",
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
              _buildFavoriteButton(food),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
