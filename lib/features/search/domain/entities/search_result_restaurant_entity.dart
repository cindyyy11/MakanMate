import 'package:equatable/equatable.dart';

class SearchResultRestaurantEntity extends Equatable {
  final String id;
  final String businessName;
  final String? cuisineType;
  final double? ratingAverage;
  final String? bannerImageUrl;
  final String? businessLogoUrl;
  final String? priceRange;

  const SearchResultRestaurantEntity({
    required this.id,
    required this.businessName,
    this.cuisineType,
    this.ratingAverage,
    this.bannerImageUrl,
    this.businessLogoUrl,
    this.priceRange,
  });

  @override
  List<Object?> get props => [
        id,
        businessName,
        cuisineType,
        ratingAverage,
        bannerImageUrl,
        businessLogoUrl,
        priceRange,
      ];
}
