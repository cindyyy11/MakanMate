import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';

class VendorProfileEntity extends Equatable {
  final String id;
  final String? profilePhotoUrl;
  final String? businessLogoUrl;
  final String? bannerImageUrl;
  final String businessName;
  final String? cuisineType;
  final String contactNumber;
  final String emailAddress;
  final String businessAddress;
  final String shortDescription;
  final String? priceRange;
  final double? ratingAverage;
  final String approvalStatus;
  final Map<String, OperatingHours> operatingHours;
  final List<OutletEntity> outlets;
  final List<CertificationEntity> certifications;
  final List<MenuItemEntity> menuItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? rejectedAt;
  final String? rejectedBy; // Admin user ID
  final String? rejectionReason;
  final double? latitude;
  final double? longitude;

  // Suspension fields
  final DateTime? suspendedAt;
  final String? suspendedBy; // Admin user ID
  final String? suspensionReason;
  final DateTime? suspendedUntil;

  // Deactivation fields
  final DateTime? deactivatedAt;
  final String? deactivatedBy; // Admin user ID
  final String? deactivationReason;

  const VendorProfileEntity({
    required this.id,
    this.profilePhotoUrl,
    this.businessLogoUrl,
    this.bannerImageUrl,
    required this.businessName,
    required this.cuisineType,
    required this.contactNumber,
    required this.emailAddress,
    required this.businessAddress,
    required this.operatingHours,
    required this.shortDescription,
    this.priceRange,
    this.ratingAverage,
    this.approvalStatus = 'pending',
    this.outlets = const [],
    this.certifications = const [],
    this.menuItems = const [],
    required this.createdAt,
    required this.updatedAt,
    this.rejectedAt,
    this.rejectedBy,
    this.rejectionReason,
    this.suspendedAt,
    this.suspendedBy,
    this.suspensionReason,
    this.suspendedUntil,
    this.deactivatedAt,
    this.deactivatedBy,
    this.deactivationReason,
    this.longitude,
    this.latitude,
  });

  VendorProfileEntity copyWith({
    String? id,
    String? profilePhotoUrl,
    String? businessLogoUrl,
    String? bannerImageUrl,
    String? businessName,
    String? cuisineType,
    String? contactNumber,
    String? emailAddress,
    String? businessAddress,
    Map<String, OperatingHours>? operatingHours,
    String? shortDescription,
    String? priceRange,
    double? ratingAverage,
    String? approvalStatus,
    List<OutletEntity>? outlets,
    List<CertificationEntity>? certifications,
    List<MenuItemEntity>? menuItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? rejectedAt,
    String? rejectedBy,
    String? rejectionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
    String? suspensionReason,
    DateTime? suspendedUntil,
    DateTime? deactivatedAt,
    String? deactivatedBy,
    String? deactivationReason,
    double? latitude,
    double? longitude,
  }) {
    return VendorProfileEntity(
      id: id ?? this.id,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      businessName: businessName ?? this.businessName,
      cuisineType: cuisineType ?? this.cuisineType,
      contactNumber: contactNumber ?? this.contactNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      businessAddress: businessAddress ?? this.businessAddress,
      operatingHours: operatingHours ?? this.operatingHours,
      shortDescription: shortDescription ?? this.shortDescription,
      priceRange: priceRange ?? this.priceRange,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      outlets: outlets ?? this.outlets,
      certifications: certifications ?? this.certifications,
      menuItems: menuItems ?? this.menuItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      deactivatedBy: deactivatedBy ?? this.deactivatedBy,
      deactivationReason: deactivationReason ?? this.deactivationReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    profilePhotoUrl,
    businessLogoUrl,
    bannerImageUrl,
    businessName,
    cuisineType,
    contactNumber,
    emailAddress,
    businessAddress,
    operatingHours,
    shortDescription,
    priceRange,
    ratingAverage,
    approvalStatus,
    outlets,
    certifications,
    menuItems,
    createdAt,
    updatedAt,
    rejectedAt,
    rejectedBy,
    rejectionReason,
    suspendedAt,
    suspendedBy,
    suspensionReason,
    suspendedUntil,
    deactivatedAt,
    deactivatedBy,
    deactivationReason,
    latitude,
    longitude,
  ];
}

class CertificationEntity extends Equatable {
  final String id;
  final String type;
  final String? certificateImageUrl;
  final String? certificateNumber;
  final DateTime? expiryDate;
  final CertificationStatus status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CertificationEntity({
    required this.id,
    required this.type,
    this.certificateImageUrl,
    this.certificateNumber,
    this.expiryDate,
    this.status = CertificationStatus.pending,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  CertificationEntity copyWith({
    String? id,
    String? type,
    String? certificateImageUrl,
    String? certificateNumber,
    DateTime? expiryDate,
    CertificationStatus? status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CertificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      certificateImageUrl: certificateImageUrl ?? this.certificateImageUrl,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    certificateImageUrl,
    certificateNumber,
    expiryDate,
    status,
    verifiedBy,
    verifiedAt,
    rejectionReason,
    createdAt,
    updatedAt,
  ];
}

enum CertificationStatus { pending, verified, rejected }

class OperatingHours extends Equatable {
  final String day;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const OperatingHours({
    required this.day,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [day, openTime, closeTime, isClosed];
}

class OutletEntity extends Equatable {
  final String id;
  final String name;
  final String? cuisineType;
  final String address;
  final String contactNumber;
  final Map<String, OperatingHours> operatingHours;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OutletEntity({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.address,
    required this.contactNumber,
    required this.operatingHours,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    cuisineType,
    address,
    contactNumber,
    operatingHours,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
}
