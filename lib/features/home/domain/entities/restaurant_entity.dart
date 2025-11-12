import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String address;
  final String cuisineType;
  final String priceRange;
  final bool isHalal;
  final bool isVegetarian;
  final double latitude;
  final double longitude;
  final List<String> openingHours;

  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.address,
    required this.cuisineType,
    required this.priceRange,
    required this.isHalal,
    required this.isVegetarian,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
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
