import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {

  const PromotionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    super.discountPercentage,
    super.flatDiscountAmount,
    super.buyQuantity,
    super.getQuantity,
    required super.imageUrl,
    required super.startDate,
    required super.expiryDate,
    required super.createdAt,
    super.approvedAt,
    super.approvedBy,
    super.clickCount,
    super.redeemedCount,
    super.conversionRate,
    super.vendorId,
    super.vendorName,
  });

  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      try {
        if (value is Timestamp) return value.toDate();
        if (value is DateTime) return value;
        if (value is String) return DateTime.parse(value);
      } catch (_) {}
      return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return PromotionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: _parsePromotionType(map['type']),
      status: _parsePromotionStatus(map['status']),
      discountPercentage: map['discountPercentage']?.toDouble(),
      flatDiscountAmount: map['flatDiscountAmount']?.toDouble(),
      buyQuantity: map['buyQuantity'],
      getQuantity: map['getQuantity'],
      imageUrl: map['imageUrl'] ?? '',
      startDate: parseDate(map['startDate'], fallback: DateTime.now()),
      expiryDate: parseDate(map['expiryDate'], fallback: DateTime.now()),
      createdAt: parseDate(map['createdAt'], fallback: DateTime.now()),
      approvedAt: map['approvedAt'] != null
          ? parseDate(map['approvedAt'])
          : null,
      approvedBy: map['approvedBy'],
      clickCount: (map['clickCount'] as num?)?.toInt() ?? 0,
      redeemedCount: (map['redeemedCount'] as num?)?.toInt() ?? 0,
      conversionRate: _calculateConversionRate(
        (map['clickCount'] as num?)?.toInt() ?? 0,
        (map['redeemedCount'] as num?)?.toInt() ?? 0,
      ),
      vendorId: map['vendorId'] as String?,
      vendorName: map['vendorName'] as String?,
    );
  }

  factory PromotionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final vendorId = doc.reference.parent.parent?.id ??
        data['vendorId'] as String?;

    return PromotionModel.fromMap({
      'id': doc.id,
      'vendorId': vendorId,
      ...data,
    });
  }

  PromotionEntity toEntity() => this;

  static double _calculateConversionRate(int clickCount, int redeemedCount) {
    if (clickCount == 0) return 0.0;
    return (redeemedCount / clickCount) * 100;
  }

  static PromotionType _parsePromotionType(String? type) {
    switch (type) {
      case 'buyXGetY':
        return PromotionType.buyXGetY;
      case 'discount':
        return PromotionType.discount;
      case 'birthday':
        return PromotionType.birthday;
      case 'flatDiscount':
        return PromotionType.flatDiscount;
      default:
        return PromotionType.discount;
    }
  }

  static PromotionStatus _parsePromotionStatus(String? status) {
    switch (status) {
      case 'pending':
        return PromotionStatus.pending;
      case 'approved':
        return PromotionStatus.approved;
      case 'rejected':
        return PromotionStatus.rejected;
      case 'active':
        return PromotionStatus.active;
      case 'expired':
        return PromotionStatus.expired;
      case 'deactivated':
        return PromotionStatus.deactivated;
      default:
        return PromotionStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': _promotionTypeToString(type),
      'status': _promotionStatusToString(status),
      'discountPercentage': discountPercentage,
      'flatDiscountAmount': flatDiscountAmount,
      'buyQuantity': buyQuantity,
      'getQuantity': getQuantity,
      'imageUrl': imageUrl,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'clickCount': clickCount,
      'redeemedCount': redeemedCount,
      'conversionRate': conversionRate,
    };
  }

  String _promotionTypeToString(PromotionType type) {
    switch (type) {
      case PromotionType.buyXGetY:
        return 'buyXGetY';
      case PromotionType.discount:
        return 'discount';
      case PromotionType.birthday:
        return 'birthday';
      case PromotionType.flatDiscount:
        return 'flatDiscount';
    }
  }

  String _promotionStatusToString(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.pending:
        return 'pending';
      case PromotionStatus.approved:
        return 'approved';
      case PromotionStatus.rejected:
        return 'rejected';
      case PromotionStatus.active:
        return 'active';
      case PromotionStatus.expired:
        return 'expired';
      case PromotionStatus.deactivated:
        return 'deactivated';
    }
  }
}

