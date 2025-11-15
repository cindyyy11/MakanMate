import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:url_launcher/url_launcher.dart';

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

    setState(() => loading = false);
  }

  Future<VendorProfileEntity> _loadVendor(String vendorId) async {
    final doc =
        await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();

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
      profilePhotoUrl: d['profilePhotoUrl'],
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
        query = query.orderBy('rating', descending: true).orderBy('createdAt', descending: true);
        break;

      case "lowest":
        query = query.orderBy('rating', descending: false).orderBy('createdAt', descending: true);
        break;

      case "helpful":
        query = query.orderBy('helpfulCount', descending: true).orderBy('createdAt', descending: true);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        title: Text(vendor!.businessName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner(),
          const SizedBox(height: 16),
          _header(),
          const SizedBox(height: 12),
          _ratingSummary(),
          const SizedBox(height: 16),
          _tags(),
          const SizedBox(height: 16),
          _rateButton(),
          const SizedBox(height: 24),
          _menuSection(),
          const SizedBox(height: 24),
          _operatingHoursSection(),
          const SizedBox(height: 24),
          _directionsSection(),
          const SizedBox(height: 32),
          _reviewsSection(),
        ],
      ),
    );
  }

  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        vendor!.bannerImageUrl ?? vendor!.businessLogoUrl ?? "",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(height: 200, color: Colors.grey[300]),
      ),
    );
  }

  Widget _header() {
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),

                Text(
                  avg > 0 ? avg.toStringAsFixed(1) : "-",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(width: 6),

                if (count > 0)
                  Text(
                    "($count reviews)",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _ratingSummary() {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
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
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text("$count reviews",
                      style:
                          TextStyle(color: Colors.grey[700], fontSize: 14)),
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
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: Colors.grey[300],
                          color: Colors.amber,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          "$starCount",
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
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

  Widget _tags() {
    return Wrap(
      spacing: 10,
      children: [
        if (vendor!.cuisineType != null) _tag(vendor!.cuisineType!),
        if (vendor!.priceRange != null) _tag(vendor!.priceRange!),
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }

  Widget _rateButton() {
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
                      remoteDataSource: UserReviewRemoteDataSourceImpl(
                        FirebaseFirestore.instance,
                      ),
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
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Rate This Restaurant",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Menu",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (menuItems.isEmpty) const Text("No items available."),
        if (menuItems.isNotEmpty)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: menuItems.map((m) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        m.imageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(height: 100, color: Colors.grey[300]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "RM ${m.price.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _operatingHoursSection() {
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
        const Text(
          "Operating Hours",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hours.isEmpty) const Text("Operating hours not available."),
        if (hours.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
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
                      Text(e.key),
                      Text(
                        oh.isClosed
                            ? "Closed"
                            : "${oh.openTime ?? '-'} - ${oh.closeTime ?? '-'}",
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

  Widget _directionsSection() {
    final address = selectedOutlet?.address ?? vendor!.businessAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Directions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
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
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMapsWithAddress(address),
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text(
                    "Get Directions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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

  Widget _reviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _sortingBar(),
        const SizedBox(height: 8),
        _reviewsList(),
      ],
    );
  }

  Widget _sortingBar() {
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

  Widget _reviewsList() {
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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("No reviews yet."),
          );
        }

        return Column(
          children: docs.map((doc) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 6,
                  )
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
                      Text(rating.toStringAsFixed(1)),
                      const Spacer(),
                      Text(
                        dateStr,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map((t) => Chip(
                                label: Text(t.toString()),
                                backgroundColor: Colors.grey[200],
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  if (tags.isNotEmpty) const SizedBox(height: 8),
                  if (imageUrls.isNotEmpty)
                    _reviewImages(
                        imageUrls.map((e) => e.toString()).toList()),
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
                          style: const TextStyle(fontSize: 13),
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

  Widget _reviewImages(List<String> urls) {
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
                    color: Colors.grey[300],
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
