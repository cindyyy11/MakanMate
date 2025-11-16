import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String itemId;
  final String restaurantId;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final Map<String, double> aspectRatings;
  final List<String> tags;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? vendorReplyText;
  final DateTime? vendorReplyAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.itemId,
    required this.restaurantId,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.aspectRatings = const {},
    this.tags = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.vendorReplyText,
    this.vendorReplyAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        itemId,
        restaurantId,
        rating,
        comment,
        imageUrls,
        aspectRatings,
        tags,
        helpfulCount,
        createdAt,
        updatedAt,
        vendorReplyText,
        vendorReplyAt,
      ];
}


