import '../../../vendor/domain/entities/vendor_profile_entity.dart';

class RestaurantEntity {
  final VendorProfileEntity vendor;
  final List<MenuItemEntity> menuItems;
  final String? cuisine;
  final String? priceRange;
  final double? ratingAverage;

  const RestaurantEntity({
    required this.vendor,
    required this.menuItems,
    this.cuisine,
    this.priceRange,
    this.ratingAverage,
  });

  @override
  List<Object> get props => [
    id,
    name,
    rating,
    description,
    imageUrl,
    address,
    cuisineType,
    priceRange,
    isVegetarian,
    isHalal,
    latitude,
    longitude,
    openingHours,
  ];
}
