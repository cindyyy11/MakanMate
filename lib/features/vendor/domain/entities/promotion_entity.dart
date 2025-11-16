enum PromotionType {
  buyXGetY, // Buy One Get One Free
  discount, // Percentage off
  birthday, // Birthday voucher
  flatDiscount, // Fixed amount off
}

enum PromotionStatus {
  pending,
  approved, 
  rejected, 
  active, 
  expired, 
  deactivated, 
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
  final int clickCount; // Number of clicks on promotion
  final int redeemedCount; // Number of redemptions
  final double conversionRate; // (redeemedCount / clickCount) * 100, 0 if clickCount is 0
  final String? vendorId; 
  final String? vendorName; /// Vendor ID who owns this promotion (for user-side)

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
    this.clickCount = 0,
    this.redeemedCount = 0,
    this.conversionRate = 0.0,
    this.vendorId,
    this.vendorName,
  });

  // Helper method to get display text for promotion
  String getDisplayText() {
    switch (type) {
      case PromotionType.buyXGetY:
        return 'Buy $buyQuantity Get $getQuantity';
      case PromotionType.discount:
        return '${discountPercentage?.toStringAsFixed(0)}% OFF';
      case PromotionType.birthday:
        return 'Birthday Special';
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

