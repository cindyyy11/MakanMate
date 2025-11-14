import 'package:equatable/equatable.dart';

/// Vendor application entity (Domain layer)
class VendorApplicationEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String businessName;
  final String businessType;
  final String? cuisineType;
  final String? businessDescription;
  final String? phoneNumber;
  final String? address;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final Map<String, dynamic> additionalData;

  const VendorApplicationEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.businessName,
    required this.businessType,
    required this.cuisineType,
    this.businessDescription,
    this.phoneNumber,
    this.address,
    this.status = 'pending',
    required this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.additionalData = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        email,
        businessName,
        businessType,
        cuisineType,
        businessDescription,
        phoneNumber,
        address,
        status,
        submittedAt,
        approvedAt,
        rejectedAt,
        rejectionReason,
        additionalData,
      ];
}

