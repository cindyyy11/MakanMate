import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vendor_profile_entity.dart';

class VendorProfileModel {
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
  final String? cuisine;
  final String? priceRange;
  final double? ratingAverage;
  final String approvalStatus;
  final Map<String, OperatingHours> operatingHours;
  final List<OutletEntity> outlets;
  final List<CertificationEntity> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VendorProfileModel({
    required this.id,
    this.profilePhotoUrl,
    this.businessLogoUrl,
    this.bannerImageUrl,
    required this.businessName,
    required this.cuisineType,
    required this.contactNumber,
    required this.emailAddress,
    required this.businessAddress,
    required this.shortDescription,
    this.cuisine,
    this.priceRange,
    this.ratingAverage,
    this.approvalStatus = 'pending',
    required this.operatingHours,
    required this.outlets,
    required this.certifications,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'businessLogoUrl': businessLogoUrl,
      'bannerImageUrl': bannerImageUrl,
      'businessName': businessName,
      'cuisineType': cuisineType,
      'contactNumber': contactNumber,
      'emailAddress': emailAddress,
      'businessAddress': businessAddress,
      'shortDescription': shortDescription,
      'cuisine': cuisine,
      'priceRange': priceRange,
      'ratingAverage': ratingAverage,
      'approvalStatus': approvalStatus,
      'operatingHours': operatingHours.map((key, value) => MapEntry(key, {
            'openTime': value.openTime,
            'closeTime': value.closeTime,
            'isClosed': value.isClosed,
          })),
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data['createdAt'] = Timestamp.fromDate(createdAt);
    data['updatedAt'] = Timestamp.fromDate(updatedAt);
    return data;
  }

  factory VendorProfileModel.fromEntity(VendorProfileEntity entity) {
    return VendorProfileModel(
      id: entity.id,
      profilePhotoUrl: entity.profilePhotoUrl,
      businessLogoUrl: entity.businessLogoUrl,
      bannerImageUrl: entity.bannerImageUrl,
      businessName: entity.businessName,
      cuisineType: entity.cuisineType,
      contactNumber: entity.contactNumber,
      emailAddress: entity.emailAddress,
      businessAddress: entity.businessAddress,
      shortDescription: entity.shortDescription,
      cuisine: entity.cuisine,
      priceRange: entity.priceRange,
      ratingAverage: entity.ratingAverage,
      approvalStatus: entity.approvalStatus,
      operatingHours: entity.operatingHours,
      outlets: entity.outlets,
      certifications: entity.certifications,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory VendorProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final operatingHoursMap = <String, OperatingHours>{};
    final rawHours = data['operatingHours'] as Map<String, dynamic>?;

    if (rawHours != null) {
      rawHours.forEach((day, value) {
        final map = value as Map<String, dynamic>;
        operatingHoursMap[day] = OperatingHours(
          day: day,
          openTime: map['openTime'],
          closeTime: map['closeTime'],
          isClosed: map['isClosed'] ?? false,
        );
      });
    }

    return VendorProfileModel(
      id: doc.id,
      profilePhotoUrl: data['profilePhotoUrl'],
      businessLogoUrl: data['businessLogoUrl'],
      bannerImageUrl: data['bannerImageUrl'],
      businessName: data['businessName'] ?? '',
      cuisineType: data['cuisineType'],
      contactNumber: data['contactNumber'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      businessAddress: data['businessAddress'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      cuisine: data['cuisine'],
      priceRange: data['priceRange'],
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble(),
      approvalStatus: data['approvalStatus'] ?? 'pending',
      operatingHours: operatingHoursMap,
      outlets: const [],
      certifications: const [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  VendorProfileEntity toEntity() {
    return VendorProfileEntity(
      id: id,
      profilePhotoUrl: profilePhotoUrl,
      businessLogoUrl: businessLogoUrl,
      bannerImageUrl: bannerImageUrl,
      businessName: businessName,
      cuisineType: cuisineType,
      contactNumber: contactNumber,
      emailAddress: emailAddress,
      businessAddress: businessAddress,
      operatingHours: operatingHours,
      shortDescription: shortDescription,
      cuisine: cuisine,
      priceRange: priceRange,
      ratingAverage: ratingAverage,
      approvalStatus: approvalStatus,
      outlets: outlets,
      certifications: certifications,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
