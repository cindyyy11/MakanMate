import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

class RestaurantLoader {
  final FirebaseFirestore firestore;

  RestaurantLoader(this.firestore);

  Future<RestaurantEntity> loadRestaurant(String vendorId) async {
    final vendorDoc =
        await firestore.collection('vendors').doc(vendorId).get();

    final data = vendorDoc.data()!;
    final vendor = VendorProfileEntity(
      id: vendorId,
      businessName: data['businessName'] ?? '',
      cuisineType: data['cuisineType'],
      contactNumber: data['contactNumber'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      businessAddress: data['businessAddress'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      priceRange: data['priceRange'],
      ratingAverage: (data['ratingAverage'] is int)
          ? (data['ratingAverage'] as int).toDouble()
          : data['ratingAverage']?.toDouble(),
      approvalStatus: data['approvalStatus'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
      businessLogoUrl: data['businessLogoUrl'],
      bannerImageUrl: data['bannerImageUrl'],
      operatingHours: {},
      outlets: const [],
      certifications: const [],
      menuItems: const [], 
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // LOAD MENU ITEMS
    final menuSnap = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menu')
        .get();

    final menuItems = menuSnap.docs.map((m) {
      final d = m.data();
      return MenuItemEntity(
        id: m.id,
        name: d['name'] ?? '',
        imageUrl: d['imageUrl'] ?? 'assets/images/logos/image-not-found.png',
        description: d['description'],
        category: d['category'],
        calories: d['calories'],
        price: (d['price'] is int)
            ? (d['price'] as int).toDouble()
            : (d['price'] ?? 0).toDouble(),
        available: d['available'] ?? true,
      );
    }).toList();

    final vendorWithMenu = vendor.copyWith(menuItems: menuItems);

    return RestaurantEntity(
      vendor: vendorWithMenu,
      menuItems: menuItems,
      cuisineType: vendorWithMenu.cuisineType,
      priceRange: vendorWithMenu.priceRange,
      ratingAverage: vendorWithMenu.ratingAverage,
    );
  }
}
