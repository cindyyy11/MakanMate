import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

import '../../../vendor/data/models/vendor_profile_model.dart';
import '../../../vendor/data/models/menu_item_model.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel {
  final VendorProfileModel vendorModel;
  final List<MenuItemModel> menuItemModels;

  RestaurantModel({
    required this.vendorModel,
    required this.menuItemModels,
  });

  /// Create RestaurantModel from vendor document
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final vendor = VendorProfileModel.fromFirestore(doc);

    // If vendor stores menu items array
    final rawMenu = doc.data() is Map<String, dynamic>
        ? (doc.data() as Map<String, dynamic>)['menuItems'] ?? []
        : [];

    final menuModels = rawMenu.map<MenuItemModel>((item) {
      return MenuItemModel.fromMap(Map<String, dynamic>.from(item));
    }).toList();

    return RestaurantModel(
      vendorModel: vendor,
      menuItemModels: menuModels,
    );
  }

  /// Convert this model to RestaurantEntity
  RestaurantEntity toEntity() {
    return RestaurantEntity(
      vendor: vendorModel.toEntity() as VendorProfileEntity,
      menuItems:
          menuItemModels.map<MenuItemEntity>((m) => m.toEntity()).toList(),
      cuisineType: vendorModel.cuisineType,
      priceRange: vendorModel.priceRange,
      ratingAverage: vendorModel.ratingAverage,
    );
  }
}
