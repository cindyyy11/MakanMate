import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';   // <-- ADDED
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';

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

  // Load Vendor (including outlets)
  Future<VendorProfileEntity> _loadVendor(String vendorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .get();

    final data = doc.data() ?? {};

    VendorProfileEntity vendor = _mapVendor(data);

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
        createdAt:
            (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();

    return vendor.copyWith(outlets: outlets);
  }

  // Load Menu Items
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

  // Map Vendor Profile
  VendorProfileEntity _mapVendor(Map<String, dynamic> d) {
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
      id: d['id'] ?? "",
      businessName: d['businessName'] ?? "",
      businessAddress: d['businessAddress'] ?? "",
      businessLogoUrl: d['businessLogoUrl'],
      bannerImageUrl: d['bannerImageUrl'],
      profilePhotoUrl: d['profilePhotoUrl'],
      cuisineType: d['cuisineType'],
      shortDescription: d['shortDescription'] ?? "",
      contactNumber: d['contactNumber'] ?? "",
      emailAddress: d['emailAddress'] ?? "",
      cuisine: d['cuisine'],
      priceRange: d['priceRange'],
      ratingAverage:
          d['ratingAverage'] != null ? (d['ratingAverage'] as num).toDouble() : null,
      approvalStatus: d['approvalStatus'] ?? "verified",
      operatingHours: hours,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      outlets: const [],
      certifications: const [],
      menuItems: const [],
    );
  }

  // Open Google Maps using address
  Future<void> _openGoogleMapsWithAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encoded",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch Google Maps");
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
          const SizedBox(height: 16),
          _tags(),
          const SizedBox(height: 24),
          _menuSection(),
          const SizedBox(height: 24),
          _operatingHoursSection(),
          const SizedBox(height: 24),
          _directionsSection(),   // <-- UPDATED
        ],
      ),
    );
  }

  // UI COMPONENTS

  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        vendor!.bannerImageUrl ?? vendor!.businessLogoUrl ?? "",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _header() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        vendor!.businessName,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 8),

      Row(
        children: [
          const Icon(Icons.star, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            vendor!.ratingAverage?.toStringAsFixed(1) ?? "-",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),

      const SizedBox(height: 12),
    ],
  );
}

  Widget _tags() {
    return Wrap(
      spacing: 10,
      children: [
        if (vendor!.cuisineType != null)
          _tag(vendor!.cuisineType!),
        if (vendor!.priceRange != null)
          _tag(vendor!.priceRange!),
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

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Menu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (menuItems.isEmpty)
          const Text("No items available."),

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
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)
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
                        errorBuilder: (_, __, ___) => Container(
                          height: 100,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(m.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Text("RM ${m.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.grey)),
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

    // Correct weekday order
    final List<String> weekdayOrder = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    // Sort map entries by weekday order
    final sortedEntries = hours.entries.toList()
      ..sort((a, b) =>
          weekdayOrder.indexOf(a.key).compareTo(weekdayOrder.indexOf(b.key)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operating Hours",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (hours.isEmpty)
          const Text("Operating hours not available."),

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


  // Get Directions Section (GrabFood style)
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
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMapsWithAddress(address),
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text(
                    "Get Directions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // GrabFood green
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
}
