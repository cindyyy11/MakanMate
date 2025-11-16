import 'package:equatable/equatable.dart';

class SearchResultFoodEntity extends Equatable {
  final String id;
  final String vendorId;
  final String vendorName;
  final String name;
  final String? imageUrl;
  final double price;
  final String? description;
  final String? category;
  final int? calories;
  final bool available;

  const SearchResultFoodEntity({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.name,
    this.imageUrl,
    required this.price,
    this.description,
    this.category,
    this.calories,
    required this.available,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        vendorName,
        name,
        imageUrl,
        price,
        description,
        category,
        calories,
        available,
      ];
}
