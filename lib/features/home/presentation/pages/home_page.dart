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
import 'package:makan_mate/features/home/presentation/widgets/ai_recommendations_section.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
import 'package:makan_mate/features/map/presentation/pages/map_page.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_event.dart' as map;
import 'package:makan_mate/core/widgets/announcements_banner.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildInitialLoader(theme);
          } else if (state is HomeLoaded) {
            return _buildBody(
              theme: theme,
              allRestaurants: state.allRestaurants,
              categories: state.categories,
              recommendations: state.recommendations,
              isPersonalized: state.isPersonalized,
            );
          } else if (state is HomeError) {
            return _buildErrorState(theme, state.message);
          }
          return _buildInitialLoader(theme);
        },
      ),
    );
  }

  Widget _buildInitialLoader(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your food experience...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Loading Home',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message.isEmpty ? 'Something went wrong. Please try again.' : message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final iconColor = theme.appBarTheme.iconTheme?.color ??
        theme.colorScheme.onPrimary;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Icon(Icons.restaurant_menu, color: primary, size: 28),
          const SizedBox(width: 8),
          Text(
            'MakanMate',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: iconColor),
    );
  }

  Widget _buildBody({
    required ThemeData theme,
    required List<RestaurantEntity> allRestaurants,
    required List<RestaurantEntity> categories,
    required List<RestaurantEntity> recommendations,
    required bool isPersonalized,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    String? userRole;
    if (user != null) {
      userRole = 'all'; // adjust when you have role logic
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnnouncementsBanner(userRole: userRole),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeSection(theme),
              const SizedBox(height: 20),
              _buildSearchBar(theme),
              const SizedBox(height: 24),

              Text(
                'Nearby Restaurants',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _buildMapSection(theme),
              const SizedBox(height: 24),

              _buildCategoriesSection(theme, categories),
              const SizedBox(height: 24),

              // AI Recommendations Section
              const AIRecommendationsSection(),
              const SizedBox(height: 24),

              _buildRecommendationsSection(
                theme,
                allRestaurants,
                recommendations,
                isPersonalized,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    // Keep orange branding but still look fine in dark mode
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.85),
            primary,
          ],
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
              children: [
                Text(
                  'Hello, Foodie!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover amazing local food around you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.restaurant, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/search');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.hintColor),
            const SizedBox(width: 12),
            Text(
              "Search for food, restaurants...",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.12),
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

  Widget _buildCategoriesSection(
    ThemeData theme,
    List<RestaurantEntity> categories,
  ) {
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
                          child: CategoryRestaurantPage(
                            categoryName: cuisineType,
                          ),
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
                          color: primary.withOpacity(
                              isDark ? 0.25 : 0.1), // subtle in both modes
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.fastfood, color: primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cuisineType,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildRecommendationsSection(
    ThemeData theme,
    List<RestaurantEntity> allRestaurants,
    List<RestaurantEntity> recommendations,
    bool personalized,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              personalized ? 'Recommended for You' : 'Popular Restaurants',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AllRestaurantsPage(restaurants: allRestaurants),
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
            return _buildFoodCard(theme, food);
          },
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(ThemeData theme, RestaurantEntity food) {
    final vendor = food.vendor;
    final isDark = theme.brightness == Brightness.dark;

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
            color: isFavorited
                ? Colors.red
                : (isDark
                    ? Colors.white70
                    : theme.iconTheme.color ?? Colors.grey),
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

  Widget _buildFoodCard(ThemeData theme, RestaurantEntity food) {
    final vendor = food.vendor;
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

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
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black.withOpacity(0.08),
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
                    color: theme.dividerColor.withOpacity(0.3),
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.shortDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.75),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 16),
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        Text(
                          vendor.priceRange ?? "-",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildFavoriteButton(theme, food),
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
