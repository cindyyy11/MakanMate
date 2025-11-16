import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';

class SearchRestaurantModel {
  final String id;
  final String businessName;
  final String? cuisineType;
  final double? ratingAverage;
  final String? bannerImageUrl;
  final String? businessLogoUrl;
  final String? priceRange;

  SearchRestaurantModel({
    required this.id,
    required this.businessName,
    this.cuisineType,
    this.ratingAverage,
    this.bannerImageUrl,
    this.businessLogoUrl,
    this.priceRange,
  });

  factory SearchRestaurantModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SearchRestaurantModel(
      id: doc.id,
      businessName: data['businessName'] ?? '',
      cuisineType: data['cuisineType'],
      ratingAverage:
          (data['ratingAverage'] is int) ? (data['ratingAverage'] as int).toDouble() : data['ratingAverage']?.toDouble(),
      bannerImageUrl: data['bannerImageUrl'],
      businessLogoUrl: data['businessLogoUrl'],
      priceRange: data['priceRange'],
    );
  }

  SearchResultRestaurantEntity toEntity() {
    return SearchResultRestaurantEntity(
      id: id,
      businessName: businessName,
      cuisineType: cuisineType,
      ratingAverage: ratingAverage,
      bannerImageUrl: bannerImageUrl,
      businessLogoUrl: businessLogoUrl,
      priceRange: priceRange,
    );
  }
}
