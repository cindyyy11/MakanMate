import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/base_model.dart';

part 'review_models.g.dart';

@JsonSerializable()
class Review extends BaseModel {
  final String id;
  final String userId;
  final String itemId;
  final String restaurantId;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final Map<String, double> aspectRatings; // taste, service, value, etc.
  final List<String> tags;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.userId,
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
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review.fromJson({'id': doc.id, ...data});
  }

  @override
  List<Object?> get props => [
    id,
    userId,
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
  ];
}
