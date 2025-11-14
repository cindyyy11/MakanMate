import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';

/// Review data model (Data layer)
/// Extends ReviewEntity and handles Firestore conversion
/// Note: itemId references MenuItemModel.id - the id field of the menu item being reviewed
/// Note: vendorId references VendorProfileModel.id - vendors collection contains menu items as subcollection
/// Note: outletId references OutletEntity.id - the specific outlet/branch the review is for
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.itemId, // References MenuItemModel.id
    required super.vendorId, // References VendorProfileModel.id
    super.outletId, // References OutletEntity.id
    required super.rating,
    required super.comment,
    super.imageUrls,
    super.aspectRatings,
    super.tags,
    super.helpfulCount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ReviewModel from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      itemId: data['itemId'] as String? ?? '',
      vendorId: data['vendorId'] as String? ?? data['restaurantId'] as String? ?? '',
      outletId: data['outletId'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      aspectRatings: Map<String, double>.from(
        (data['aspectRatings'] as Map?)?.map(
              (key, value) =>
                  MapEntry(key.toString(), (value as num).toDouble()),
            ) ??
            {},
      ),
      tags: List<String>.from(data['tags'] ?? []),
      helpfulCount: (data['helpfulCount'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert ReviewModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'vendorId': vendorId,
      if (outletId != null) 'outletId': outletId,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'aspectRatings': aspectRatings,
      'tags': tags,
      'helpfulCount': helpfulCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert ReviewModel to ReviewEntity
  ReviewEntity toEntity() => this;
}
