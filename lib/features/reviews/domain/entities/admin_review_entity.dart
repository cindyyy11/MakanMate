import 'package:equatable/equatable.dart';

/// Admin Review Entity with user and vendor information
class AdminReviewEntity extends Equatable {
  final String id;
  final String userId;

  /// References MenuItemEntity.id - this should match the id field of the menu item being reviewed
  final String itemId;

  /// References VendorProfileEntity.id - vendors collection contains menu items as subcollection
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

  // User information (denormalized for admin display)
  final String? userName;
  final String? userEmail;
  final String? userProfileImageUrl;

  // Vendor information (denormalized for admin display)
  final String? vendorName;
  final List<String> vendorImageUrls;

  const AdminReviewEntity({
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
    this.userName,
    this.userEmail,
    this.userProfileImageUrl,
    this.vendorName,
    this.vendorImageUrls = const [],
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
    vendorReplyText,
    vendorReplyAt,
    flagged,
    flagReason,
    flaggedAt,
    flaggedBy,
    removed,
    removedAt,
    removedBy,
    removalReason,
    moderatedAt,
    moderatedBy,
    moderationAction,
    userName,
    userEmail,
    userProfileImageUrl,
    vendorName,
    vendorImageUrls,
  ];

  AdminReviewEntity copyWith({
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
    String? vendorReplyText,
    DateTime? vendorReplyAt,
    bool? flagged,
    String? flagReason,
    DateTime? flaggedAt,
    String? flaggedBy,
    bool? removed,
    DateTime? removedAt,
    String? removedBy,
    String? removalReason,
    DateTime? moderatedAt,
    String? moderatedBy,
    String? moderationAction,
    String? userName,
    String? userEmail,
    String? userProfileImageUrl,
    String? vendorName,
    List<String>? vendorImageUrls,
  }) {
    return AdminReviewEntity(
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
      vendorReplyText: vendorReplyText ?? this.vendorReplyText,
      vendorReplyAt: vendorReplyAt ?? this.vendorReplyAt,
      flagged: flagged ?? this.flagged,
      flagReason: flagReason ?? this.flagReason,
      flaggedAt: flaggedAt ?? this.flaggedAt,
      flaggedBy: flaggedBy ?? this.flaggedBy,
      removed: removed ?? this.removed,
      removedAt: removedAt ?? this.removedAt,
      removedBy: removedBy ?? this.removedBy,
      removalReason: removalReason ?? this.removalReason,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderationAction: moderationAction ?? this.moderationAction,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      vendorName: vendorName ?? this.vendorName,
      vendorImageUrls: vendorImageUrls ?? this.vendorImageUrls,
    );
  }
}
