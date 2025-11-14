import 'package:equatable/equatable.dart';

/// Review entity (Domain layer)
/// Pure Dart class representing a review
/// Note: itemId references MenuItemEntity.id - the id field of the menu item being reviewed
/// Note: vendorId references VendorProfileEntity.id - vendors collection contains menu items as subcollection
/// Note: outletId references OutletEntity.id - the specific outlet/branch the review is for
class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String itemId; // References MenuItemEntity.id
  final String vendorId; // References VendorProfileEntity.id
  final String? outletId; // References OutletEntity.id
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final Map<String, double> aspectRatings; // taste, service, value, etc.
  final List<String> tags;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.vendorId,
    this.outletId,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.aspectRatings = const {},
    this.tags = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    vendorId,
    outletId,
    rating,
    comment,
    imageUrls,
    aspectRatings,
    tags,
    helpfulCount,
    createdAt,
    updatedAt,
  ];

  ReviewEntity copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? vendorId,
    String? outletId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    Map<String, double>? aspectRatings,
    List<String>? tags,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      vendorId: vendorId ?? this.vendorId,
      outletId: outletId ?? this.outletId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      aspectRatings: aspectRatings ?? this.aspectRatings,
      tags: tags ?? this.tags,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
