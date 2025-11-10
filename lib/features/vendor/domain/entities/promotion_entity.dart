enum PromotionType {
  buyXGetY, // Buy One Get One Free
  discount, // Percentage off
  birthday, // Birthday voucher
  flatDiscount, // Fixed amount off
}

enum PromotionStatus {
  pending, // Waiting for admin approval
  approved, // Approved by admin
  active, // Currently active
  expired, // Past expiry date
  deactivated, // Manually deactivated by vendor
}

class PromotionEntity {
  final String id;
  final String title;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final double? discountPercentage; // For discount type
  final double? flatDiscountAmount; // For flat discount type
  final int? buyQuantity; // For buy X get Y (e.g., 1)
  final int? getQuantity; // For buy X get Y (e.g., 1)
  final String imageUrl;
  final DateTime startDate;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy; // Admin user ID

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.discountPercentage,
    this.flatDiscountAmount,
    this.buyQuantity,
    this.getQuantity,
    required this.imageUrl,
    required this.startDate,
    required this.expiryDate,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  // Helper method to get display text for promotion
  String getDisplayText() {
    switch (type) {
      case PromotionType.buyXGetY:
        return 'BOGO FREE'; // Buy One Get One
      case PromotionType.discount:
        return '${discountPercentage?.toStringAsFixed(0)}% OFF';
      case PromotionType.birthday:
        return 'BIRTHDAY SPECIAL';
      case PromotionType.flatDiscount:
        return 'RM ${flatDiscountAmount?.toStringAsFixed(2)} OFF';
    }
  }

  // Helper method to get type tag text
  String getTypeTag() {
    switch (type) {
      case PromotionType.buyXGetY:
        return 'Buy X Get Y';
      case PromotionType.discount:
        return 'Discount';
      case PromotionType.birthday:
        return 'Birthday';
      case PromotionType.flatDiscount:
        return 'Flat Discount';
    }
  }

  // Check if promotion is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == PromotionStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(expiryDate);
  }

  // Check if promotion is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate) ||
        status == PromotionStatus.expired;
  }
}

