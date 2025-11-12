import 'package:equatable/equatable.dart';

class VendorProfileEntity extends Equatable {
  final String id;
  final String? profilePhotoUrl;
  final String? businessLogoUrl;
  final String businessName;
  final String contactNumber;
  final String emailAddress;
  final String businessAddress;
  final Map<String, OperatingHours> operatingHours; // Day -> OperatingHours
  final String shortDescription;
  final List<OutletEntity> outlets;
  final List<CertificationEntity> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VendorProfileEntity({
    required this.id,
    this.profilePhotoUrl,
    this.businessLogoUrl,
    required this.businessName,
    required this.contactNumber,
    required this.emailAddress,
    required this.businessAddress,
    required this.operatingHours,
    required this.shortDescription,
    this.outlets = const [],
    this.certifications = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  VendorProfileEntity copyWith({
    String? id,
    String? profilePhotoUrl,
    String? businessLogoUrl,
    String? businessName,
    String? contactNumber,
    String? emailAddress,
    String? businessAddress,
    Map<String, OperatingHours>? operatingHours,
    String? shortDescription,
    List<OutletEntity>? outlets,
    List<CertificationEntity>? certifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorProfileEntity(
      id: id ?? this.id,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      businessName: businessName ?? this.businessName,
      contactNumber: contactNumber ?? this.contactNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      businessAddress: businessAddress ?? this.businessAddress,
      operatingHours: operatingHours ?? this.operatingHours,
      shortDescription: shortDescription ?? this.shortDescription,
      outlets: outlets ?? this.outlets,
      certifications: certifications ?? this.certifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profilePhotoUrl,
        businessLogoUrl,
        businessName,
        contactNumber,
        emailAddress,
        businessAddress,
        operatingHours,
        shortDescription,
        outlets,
        certifications,
        createdAt,
        updatedAt,
      ];
}

class CertificationEntity extends Equatable {
  final String id;
  final String type; // 'Halal', 'Vegetarian', 'Alcohol-Free', 'Gluten-Free', etc.
  final String? certificateImageUrl; // URL to uploaded certificate image
  final String? certificateNumber;
  final DateTime? expiryDate;
  final CertificationStatus status; // pending, verified, rejected
  final String? verifiedBy; // Admin user ID who verified
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

enum CertificationStatus {
  pending,
  verified,
  rejected,
}

class OperatingHours extends Equatable {
  final String day;
  final String? openTime; // Format: "HH:mm"
  final String? closeTime; // Format: "HH:mm"
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
        address,
        contactNumber,
        operatingHours,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];
}

