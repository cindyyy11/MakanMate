import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../vendor/data/models/vendor_profile_model.dart';
import '../../../vendor/data/models/menu_item_model.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantEntity>> getRestaurants();
  Future<RestaurantEntity> getRestaurantById(String vendorId);

  /// Returns restaurants filtered based on the given dietary preferences.
  ///
  /// Expected structure (from users/{uid}.dietaryPreferences):
  /// {
  ///   "halalOnly": bool,
  ///   "vegetarian": bool,
  ///   "spiceTolerance": String,
  ///   "cuisinePreferences": List<String>,
  ///   "dietaryRestrictions": List<String>,
  ///   "behaviourPatterns": List<String>,
  /// }
  Future<List<RestaurantEntity>> getPersonalizedRestaurants(
    Map<String, dynamic> dietaryPrefs,
  );
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<RestaurantEntity>> getRestaurants() async {
    final snapshot = await firestore
        .collection('vendors')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    final List<RestaurantEntity> restaurants = [];

    for (final doc in snapshot.docs) {
      final vendorModel = VendorProfileModel.fromFirestore(doc);

      final menuSnapshot = await firestore
          .collection('vendors')
          .doc(doc.id)
          .collection('menu')
          .get();

      final menuModels = menuSnapshot.docs
          .map((d) => MenuItemModel.fromFirestore(d))
          .toList();

      final restaurantModel = RestaurantModel(
        vendorModel: vendorModel,
        menuItemModels: menuModels,
      );

      restaurants.add(restaurantModel.toEntity());
    }

    return restaurants;
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String vendorId) async {
    final vendorDoc = await firestore.collection('vendors').doc(vendorId).get();
    final vendorModel = VendorProfileModel.fromFirestore(vendorDoc);

    final menuSnapshot = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menu')
        .get();

    final menuModels = menuSnapshot.docs
        .map((d) => MenuItemModel.fromFirestore(d))
        .toList();

    final restaurantModel = RestaurantModel(
      vendorModel: vendorModel,
      menuItemModels: menuModels,
    );

    return restaurantModel.toEntity();
  }

  @override
  Future<List<RestaurantEntity>> getPersonalizedRestaurants(
    Map<String, dynamic> dietaryPrefs,
  ) async {
    // Re-use the same data, then filter here (no extra Firestore reads).
    final allRestaurants = await getRestaurants();

    if (dietaryPrefs.isEmpty) {
      return allRestaurants;
    }

    final bool halalOnly = dietaryPrefs['halalOnly'] == true;
    final bool vegetarian = dietaryPrefs['vegetarian'] == true;

    final List<dynamic> cuisinePrefsRaw =
        dietaryPrefs['cuisinePreferences'] ?? const [];
    final List<String> cuisinePrefs =
        cuisinePrefsRaw.map((e) => e.toString()).toList();

    // Other fields are available but not used yet:
    // final String spiceTolerance = dietaryPrefs['spiceTolerance'] ?? 'None';
    // final List<dynamic> dietaryRestrictions = dietaryPrefs['dietaryRestrictions'] ?? const [];
    // final List<dynamic> behaviourPatterns = dietaryPrefs['behaviourPatterns'] ?? const [];

    return allRestaurants.where((restaurant) {
      final vendor = restaurant.vendor;
      final cuisineType = (vendor.cuisineType ?? '').trim();

      // 1) Basic cuisine preference matching
      if (cuisinePrefs.isNotEmpty && !cuisinePrefs.contains(cuisineType)) {
        return false;
      }

      // 2) Halal / vegetarian logic placeholders
      // You can replace these with your real checks later.
      if (halalOnly) {
        // Example: if you add a field like vendor.isHalal
        // if (vendor.isHalal != true) return false;
      }

      if (vegetarian) {
        // Example: if you add a field like restaurant.hasVegetarianMenu
        // if (restaurant.hasVegetarianMenu != true) return false;
      }

      return true;
    }).toList();
  }
}
