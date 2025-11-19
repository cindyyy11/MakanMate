import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/reviews/data/datasources/user_review_remote_datasource.dart';
import 'package:makan_mate/features/reviews/data/repositories/user_review_repository_impl.dart';
import 'package:makan_mate/features/reviews/domain/usecases/submit_user_review_usecase.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:makan_mate/features/reviews/presentation/pages/submit_review_page.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';
import 'package:makan_mate/features/vendor/presentation/pages/all_menu_items_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:makan_mate/features/reviews/presentation/pages/all_reviews_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final RestaurantEntity restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  VendorProfileEntity? vendor;
  List<MenuItemEntity> menuItems = [];
  OutletEntity? selectedOutlet;

  bool loading = true;

  String selectedSort = "newest";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final vendorId = widget.restaurant.vendor.id;

    vendor = await _loadVendor(vendorId);
    menuItems = await _loadMenu(vendorId);

    if (vendor!.outlets.isNotEmpty) {
      selectedOutlet = vendor!.outlets.first;
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<VendorProfileEntity> _loadVendor(String vendorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .get();

    final data = doc.data() ?? {};

    VendorProfileEntity vendor = _mapVendor(doc.id, data);

    final outletSnap = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('outlets')
        .get();

    List<OutletEntity> outlets = outletSnap.docs.map((doc) {
      final d = doc.data();
      final hours = <String, OperatingHours>{};

      if (d['operatingHours'] != null) {
        (d['operatingHours'] as Map<String, dynamic>).forEach((key, value) {
          hours[key] = OperatingHours(
            day: value['day'] ?? "",
            openTime: value['openTime'],
            closeTime: value['closeTime'],
            isClosed: value['isClosed'] ?? false,
          );
        });
      }

      return OutletEntity(
        id: doc.id,
        name: d['name'] ?? "",
        cuisineType: d['cuisineType'],
        address: d['address'] ?? "",
        contactNumber: d['contactNumber'] ?? "",
        operatingHours: hours,
        latitude: (d['latitude'] as num?)?.toDouble(),
        longitude: (d['longitude'] as num?)?.toDouble(),
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();

    return vendor.copyWith(outlets: outlets);
  }

  Future<List<MenuItemEntity>> _loadMenu(String vendorId) async {
    final snap = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('menus')
        .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return MenuItemEntity(
        id: doc.id,
        name: d['name'] ?? "",
        description: d['description'] ?? "",
        category: d['category'] ?? "",
        price: (d['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: d['imageUrl'] ?? "",
        available: d['available'] ?? true,
        calories: d['calories'] ?? 0,
      );
    }).toList();
  }

  VendorProfileEntity _mapVendor(String vendorId, Map<String, dynamic> d) {
    final hours = <String, OperatingHours>{};

    if (d['operatingHours'] != null) {
      (d['operatingHours'] as Map<String, dynamic>).forEach((key, value) {
        hours[key] = OperatingHours(
          day: value['day'] ?? "",
          openTime: value['openTime'],
          closeTime: value['closeTime'],
          isClosed: value['isClosed'] ?? false,
        );
      });
    }

    return VendorProfileEntity(
      id: vendorId,
      businessName: d['businessName'] ?? "",
      businessAddress: d['businessAddress'] ?? "",
      businessLogoUrl: d['businessLogoUrl'],
      bannerImageUrl: d['bannerImageUrl'],
      cuisineType: d['cuisineType'],
      shortDescription: d['shortDescription'] ?? "",
      contactNumber: d['contactNumber'] ?? "",
      emailAddress: d['emailAddress'] ?? "",
      priceRange: d['priceRange'],
      ratingAverage: d['ratingAverage'] != null
          ? (d['ratingAverage'] as num).toDouble()
          : null,
      approvalStatus: d['approvalStatus'] ?? "verified",
      operatingHours: hours,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      outlets: const [],
      certifications: const [],
      menuItems: const [],
    );
  }

  Future<void> _openGoogleMapsWithAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encoded",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch Google Maps");
    }
  }

  Stream<Map<String, dynamic>> _watchRatingSummary(String vendorId) {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) {
        return {
          'average': 0.0,
          'count': 0,
          'stars': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      double total = 0;
      final Map<int, int> starCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in snap.docs) {
        final data = doc.data();
        final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        total += rating;
        final key = rating.round().clamp(1, 5);
        starCount[key] = (starCount[key] ?? 0) + 1;
      }

      return {
        'average': total / snap.docs.length,
        'count': snap.docs.length,
        'stars': starCount,
      };
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchReviews(
    String vendorId,
    String sortBy,
  ) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('reviews')
        .where('vendorId', isEqualTo: vendorId);

    switch (sortBy) {
      case "oldest":
        query = query.orderBy('createdAt', descending: false);
        break;

      case "highest":
        query = query
            .orderBy('rating', descending: true)
            .orderBy('createdAt', descending: true);
        break;

      case "lowest":
        query = query
            .orderBy('rating', descending: false)
            .orderBy('createdAt', descending: true);
        break;

      case "helpful":
        query = query
            .orderBy('helpfulCount', descending: true)
            .orderBy('createdAt', descending: true);
        break;

      case "newest":
      default:
        query = query.orderBy('createdAt', descending: true);
        break;
    }

    return query.snapshots().handleError((e) {
      print("Review query error: $e");
    });
  }

  Future<void> _markHelpful(String reviewId) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .update({
      'helpfulCount': FieldValue.increment(1),
    });
  }

  void _openImageFullscreen(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(vendor!.businessName),
        centerTitle: false,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('favorites')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('items')
                .doc(vendor!.id)
                .snapshots(),
            builder: (context, snapshot) {
              final isFavorited = snapshot.data?.exists ?? false;

              return IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited
                      ? theme.colorScheme.error
                      : theme.iconTheme.color,
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final ref = FirebaseFirestore.instance
                      .collection('favorites')
                      .doc(user.uid)
                      .collection('items')
                      .doc(vendor!.id);

                  if (isFavorited) {
                    await ref.delete();
                  } else {
                    await ref.set({
                      'id': vendor!.id,
                      'name': vendor!.businessName,
                      'cuisineType': vendor!.cuisineType,
                      'rating': vendor!.ratingAverage,
                      'priceRange': vendor!.priceRange,
                      'image': vendor!.businessLogoUrl,
                      'description': vendor!.shortDescription,
                    });
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRestaurant,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner(context),
          const SizedBox(height: 16),
          _header(context),
          const SizedBox(height: 12),
          _ratingSummary(context),
          const SizedBox(height: 16),
          _tags(context),
          const SizedBox(height: 16),
          _rateButton(context),
          const SizedBox(height: 24),
          _menuSection(context),
          const SizedBox(height: 24),
          _operatingHoursSection(context),
          const SizedBox(height: 24),
          _directionsSection(context),
          const SizedBox(height: 32),
          _reviewsSection(context),
        ],
      ),
    );
  }

  void _shareRestaurant() {
    final vendorName = vendor!.businessName;
    final vendorId = vendor!.id;

    final String shareUrl =
        "https://makanmate.com/restaurant?vendorId=$vendorId";

    final message =
        "Check out this restaurant on MakanMate:\n$vendorName\n\n$shareUrl";

    Share.share(message);
  }

  Widget _banner(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        vendor!.bannerImageUrl ?? vendor!.businessLogoUrl ?? "",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(height: 200, color: theme.dividerColor),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _watchRatingSummary(vendor!.id),
      builder: (context, snapshot) {
        double avg = 0.0;
        int count = 0;

        if (snapshot.hasData) {
          avg = (snapshot.data!["average"] as num).toDouble();
          count = snapshot.data!["count"] as int;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendor!.businessName,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  avg > 0 ? avg.toStringAsFixed(1) : "-",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 6),
                if (count > 0)
                  Text(
                    "($count reviews)",
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _ratingSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<Map<String, dynamic>>(
      stream: _watchRatingSummary(vendor!.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!;
        final double avg = (data['average'] as num).toDouble();
        final int count = data['count'] as int;
        final Map<int, int> stars =
            Map<int, int>.from(data['stars'] as Map<dynamic, dynamic>);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "$count reviews",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...[5, 4, 3, 2, 1].map((star) {
                final starCount = stars[star] ?? 0;
                final ratio = count == 0 ? 0.0 : starCount / count;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          "$star★",
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: theme.dividerColor,
                          color: theme.colorScheme.primary,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          "$starCount",
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _tags(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        if (vendor!.cuisineType != null) _tag(context, vendor!.cuisineType!),
        if (vendor!.priceRange != null) _tag(context, vendor!.priceRange!),
      ],
    );
  }

  Widget _tag(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _rateButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => ReviewBloc(
                  SubmitUserReviewUseCase(
                    UserReviewRepositoryImpl(
                      remoteDataSource:
                          UserReviewRemoteDataSourceImpl(FirebaseFirestore.instance),
                      networkInfo: NetworkInfoImpl(Connectivity()),
                    ),
                  ),
                ),
                child: SubmitReviewPage(
                  vendorId: vendor!.id,
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Rate This Restaurant",
          style: theme.textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _menuSection(BuildContext context) {
    final theme = Theme.of(context);
    final limitedMenu = menuItems.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Menu",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (menuItems.length > 4)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllMenuItemsPage(
                        vendorName: vendor!.businessName,
                        items: menuItems,
                      ),
                    ),
                  );
                },
                child: const Text("See All"),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (menuItems.isEmpty)
          Text(
            "No items available.",
            style: theme.textTheme.bodyMedium,
          ),
        if (menuItems.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: limitedMenu.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final m = limitedMenu[index];
              return _menuCard(context, m);
            },
          ),
      ],
    );
  }

  Widget _menuCard(BuildContext context, MenuItemEntity m) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              m.imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 100, color: theme.dividerColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              m.name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "RM ${m.price.toStringAsFixed(2)}",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _operatingHoursSection(BuildContext context) {
    final theme = Theme.of(context);
    final hours = selectedOutlet?.operatingHours ?? vendor!.operatingHours;

    final List<String> weekdayOrder = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    final sortedEntries = hours.entries.toList()
      ..sort(
        (a, b) =>
            weekdayOrder.indexOf(a.key).compareTo(weekdayOrder.indexOf(b.key)),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Operating Hours",
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hours.isEmpty)
          Text(
            "Operating hours not available.",
            style: theme.textTheme.bodyMedium,
          ),
        if (hours.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: sortedEntries.map((e) {
                final oh = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: theme.textTheme.bodyMedium),
                      Text(
                        oh.isClosed
                            ? "Closed"
                            : "${oh.openTime ?? '-'} - ${oh.closeTime ?? '-'}",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _directionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final address = selectedOutlet?.address ?? vendor!.businessAddress;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Directions",
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMapsWithAddress(address),
                  icon: const Icon(Icons.directions, size: 20),
                  label: Text(
                    "Get Directions",
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Reviews",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllReviewsPage(
                      vendorId: vendor!.id,
                      vendorName: vendor!.businessName,
                    ),
                  ),
                );
              },
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _sortingBar(context),
        const SizedBox(height: 8),
        _reviewsList(context),
      ],
    );
  }

  Widget _sortingBar(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedSort,
          underline: Container(height: 0),
          items: const [
            DropdownMenuItem(
              value: "newest",
              child: Text("Newest"),
            ),
            DropdownMenuItem(
              value: "oldest",
              child: Text("Oldest"),
            ),
            DropdownMenuItem(
              value: "highest",
              child: Text("Highest Rating"),
            ),
            DropdownMenuItem(
              value: "lowest",
              child: Text("Lowest Rating"),
            ),
            DropdownMenuItem(
              value: "helpful",
              child: Text("Most Helpful"),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedSort = value;
            });
          },
        ),
      ],
    );
  }

  Widget _reviewsList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _watchReviews(vendor!.id, selectedSort),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "No reviews yet.",
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        final limitedDocs = docs.take(4).toList();

        return Column(
          children: limitedDocs.map((doc) {
            final r = doc.data();
            final double rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
            final String comment = r['comment']?.toString() ?? '';
            final List<dynamic> tags = r['tags'] ?? [];
            final List<dynamic> imageUrls = r['imageUrls'] ?? [];
            final int helpfulCount = (r['helpfulCount'] as int?) ?? 0;
            final Timestamp? ts = r['createdAt'] as Timestamp?;
            final String dateStr =
                ts != null ? ts.toDate().toString().split(' ').first : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // rating + date
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (t) => Chip(
                              label: Text(
                                t.toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.08),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  if (tags.isNotEmpty) const SizedBox(height: 8),
                  if (imageUrls.isNotEmpty)
                    _reviewImages(
                      context,
                      imageUrls.map((e) => e.toString()).toList(),
                    ),
                  if (imageUrls.isNotEmpty) const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _markHelpful(doc.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          helpfulCount == 0
                              ? "Helpful?"
                              : "$helpfulCount found this helpful",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _reviewImages(BuildContext context, List<String> urls) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: urls.map((url) {
          return GestureDetector(
            onTap: () => _openImageFullscreen(url),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: theme.dividerColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
