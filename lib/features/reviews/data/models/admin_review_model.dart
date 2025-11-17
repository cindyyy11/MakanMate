import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/vendor/data/models/vendor_profile_model.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';

/// Admin Review Model with user and vendor information
class AdminReviewModel {
  final String id;
  final String userId;
  /// References MenuItemModel.id - this should match the id field of the menu item being reviewed
  final String itemId;
  /// References VendorProfileModel.id - vendors collection contains menu items as subcollection
  final String vendorId;
  /// References OutletEntity.id - the specific outlet/branch the review is for
  final String? outletId;
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
  
  // Moderation fields
  final bool? flagged;
  final String? flagReason;
  final DateTime? flaggedAt;
  final String? flaggedBy;
  final bool? removed;
  final DateTime? removedAt;
  final String? removedBy;
  final String? removalReason;
  final DateTime? moderatedAt;
  final String? moderatedBy;
  final String? moderationAction;
  
  // User information (from users collection)
  final UserModel? user;
  
  // Vendor information (from vendors collection)
  final VendorProfileModel? vendor;

  AdminReviewModel({
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
    this.vendorReplyText,
    this.vendorReplyAt,
    this.flagged,
    this.flagReason,
    this.flaggedAt,
    this.flaggedBy,
    this.removed,
    this.removedAt,
    this.removedBy,
    this.removalReason,
    this.moderatedAt,
    this.moderatedBy,
    this.moderationAction,
    this.user,
    this.vendor,
  });

  /// Create AdminReviewModel from Firestore document
  /// Fetches user and restaurant data from their respective collections
  static Future<AdminReviewModel> fromFirestore(
    DocumentSnapshot doc,
    FirebaseFirestore firestore,
  ) async {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Review document data is null');
    }

    // Parse basic review fields
    final reviewId = doc.id;
    final userId = data['userId'] as String? ?? '';
    final vendorId = data['vendorId'] as String? ?? data['restaurantId'] as String? ?? '';

    // Fetch user data
    UserModel? user;
    if (userId.isNotEmpty) {
      try {
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          user = UserModel.fromFirestore(userDoc);
        }
      } catch (e) {
        // User not found or error fetching - continue without user data
      }
    }

    // Fetch vendor data
    VendorProfileModel? vendor;
    if (vendorId.isNotEmpty) {
      try {
        final vendorDoc = await firestore.collection('vendors').doc(vendorId).get();
        if (vendorDoc.exists) {
          vendor = VendorProfileModel.fromFirestore(vendorDoc);
        }
      } catch (e) {
        // Vendor not found or error fetching - continue without vendor data
      }
    }

    // Parse timestamps
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Parse vendor reply
    String? vendorReplyText;
    DateTime? vendorReplyAt;
    final vendorReply = data['vendorReply'] as Map<String, dynamic>?;
    if (vendorReply != null) {
      vendorReplyText = vendorReply['text'] as String?;
      vendorReplyAt = parseTimestamp(vendorReply['createdAt']);
    }

    return AdminReviewModel(
      id: reviewId,
      userId: userId,
      itemId: data['itemId'] as String? ?? '',
      vendorId: vendorId,
      outletId: data['outletId'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      aspectRatings: Map<String, double>.from(
        (data['aspectRatings'] as Map?)?.map(
              (key, value) => MapEntry(
                key.toString(),
                (value as num).toDouble(),
              ),
            ) ??
            {},
      ),
      tags: List<String>.from(data['tags'] ?? []),
      helpfulCount: (data['helpfulCount'] as int?) ?? 0,
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      vendorReplyText: vendorReplyText,
      vendorReplyAt: vendorReplyAt,
      flagged: data['flagged'] as bool?,
      flagReason: data['flagReason'] as String?,
      flaggedAt: parseTimestamp(data['flaggedAt']),
      flaggedBy: data['flaggedBy'] as String?,
      removed: data['removed'] as bool?,
      removedAt: parseTimestamp(data['removedAt']),
      removedBy: data['removedBy'] as String?,
      removalReason: data['removalReason'] as String?,
      moderatedAt: parseTimestamp(data['moderatedAt']),
      moderatedBy: data['moderatedBy'] as String?,
      moderationAction: data['moderationAction'] as String?,
      user: user,
      vendor: vendor,
    );
  }

  /// Convert AdminReviewModel to AdminReviewEntity
  AdminReviewEntity toEntity() {
    return AdminReviewEntity(
      id: id,
      userId: userId,
      itemId: itemId,
      vendorId: vendorId,
      outletId: outletId,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
      aspectRatings: aspectRatings,
      tags: tags,
      helpfulCount: helpfulCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vendorReplyText: vendorReplyText,
      vendorReplyAt: vendorReplyAt,
      flagged: flagged,
      flagReason: flagReason,
      flaggedAt: flaggedAt,
      flaggedBy: flaggedBy,
      removed: removed,
      removedAt: removedAt,
      removedBy: removedBy,
      removalReason: removalReason,
      moderatedAt: moderatedAt,
      moderatedBy: moderatedBy,
      moderationAction: moderationAction,
      userName: user?.name,
      userEmail: user?.email,
      userProfileImageUrl: user?.profileImageUrl,
      vendorName: vendor?.businessName,
      vendorImageUrls: [
        if (vendor?.bannerImageUrl != null) vendor!.bannerImageUrl!,
        if (vendor?.businessLogoUrl != null) vendor!.businessLogoUrl!,
      ],
    );
  }
}

