// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  userId: json['userId'] as String,
  itemId: json['itemId'] as String,
  restaurantId: json['restaurantId'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  aspectRatings:
      (json['aspectRatings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  vendorReplyText: json['vendorReplyText'] as String?,
  vendorReplyAt: json['vendorReplyAt'] == null
      ? null
      : DateTime.parse(json['vendorReplyAt'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'itemId': instance.itemId,
  'restaurantId': instance.restaurantId,
  'rating': instance.rating,
  'comment': instance.comment,
  'imageUrls': instance.imageUrls,
  'aspectRatings': instance.aspectRatings,
  'tags': instance.tags,
  'helpfulCount': instance.helpfulCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'vendorReplyText': instance.vendorReplyText,
  'vendorReplyAt': instance.vendorReplyAt?.toIso8601String(),
};
