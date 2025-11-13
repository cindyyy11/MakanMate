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
  final String? vendorReplyText;
  final DateTime? vendorReplyAt;

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
    this.vendorReplyText,
    this.vendorReplyAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final vendorReply = data['vendorReply'] as Map<String, dynamic>?;

    // Convert Firestore data to JSON format
    final jsonData = {'id': doc.id, ...data};

    // Handle vendorReply if it exists
    if (vendorReply != null) {
      jsonData['vendorReplyText'] = vendorReply['text'];
      if (vendorReply['createdAt'] != null) {
        if (vendorReply['createdAt'] is Timestamp) {
          jsonData['vendorReplyAt'] = (vendorReply['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        } else {
          jsonData['vendorReplyAt'] = vendorReply['createdAt'];
        }
      }
    }

    return Review.fromJson(jsonData);
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
    vendorReplyText,
    vendorReplyAt,
  ];
}
