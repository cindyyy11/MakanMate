import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';

import '../../../vendor/domain/entities/vendor_profile_entity.dart';

class RestaurantEntity {
  final VendorProfileEntity vendor;
  final List<MenuItemEntity> menuItems;
  final String? cuisineType;
  final String? priceRange;
  final double? ratingAverage;

  const RestaurantEntity({
    required this.vendor,
    required this.menuItems,
    this.cuisineType,
    this.priceRange,
    this.ratingAverage,
  });

  List<Object> get props => [
    vendor,
    menuItems,
    cuisineType ?? '',
    priceRange ?? '',
    ratingAverage ?? 0.0,
  ];
}
