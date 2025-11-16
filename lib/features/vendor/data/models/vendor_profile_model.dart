import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vendor_profile_entity.dart';
import 'menu_item_model.dart';

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
  final String? priceRange;
  final double? ratingAverage;
  final String approvalStatus;
  final Map<String, OperatingHours> operatingHours;
  final List<OutletEntity> outlets;
  final List<CertificationEntity> certifications;
  final List<MenuItemModel> menuItems;
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
    this.priceRange,
    this.ratingAverage,
    this.approvalStatus = 'pending',
    required this.operatingHours,
    required this.outlets,
    required this.certifications,
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
    this.latitude,
    this.longitude,
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
      'priceRange': priceRange,
      'ratingAverage': ratingAverage,
      'approvalStatus': approvalStatus,
      'operatingHours': operatingHours.map(
        (key, value) => MapEntry(key, {
          'openTime': value.openTime,
          'closeTime': value.closeTime,
          'isClosed': value.isClosed,
        }),
      ),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (rejectedAt != null) 'rejectedAt': rejectedAt,
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'outlets': outlets.map((outlet) {
        return {
          'id': outlet.id,
          'name': outlet.name,
          'cuisineType': outlet.cuisineType,
          'address': outlet.address,
          'contactNumber': outlet.contactNumber,
          'operatingHours': outlet.operatingHours.map((day, hours) {
            return MapEntry(day, {
              'openTime': hours.openTime,
              'closeTime': hours.closeTime,
              'isClosed': hours.isClosed,
            });
          }),
          'latitude': outlet.latitude,
          'longitude': outlet.longitude,
          'createdAt': Timestamp.fromDate(outlet.createdAt),
          'updatedAt': Timestamp.fromDate(outlet.updatedAt),
        };
      }).toList(),
      'certifications': certifications.map((cert) {
        return {
          'id': cert.id,
          'type': cert.type,
          'certificateImageUrl': cert.certificateImageUrl,
          'certificateNumber': cert.certificateNumber,
          'expiryDate': cert.expiryDate != null
              ? Timestamp.fromDate(cert.expiryDate!)
              : null,
          'status': cert.status.name,
          'verifiedBy': cert.verifiedBy,
          'verifiedAt': cert.verifiedAt != null
              ? Timestamp.fromDate(cert.verifiedAt!)
              : null,
          'rejectionReason': cert.rejectionReason,
          'createdAt': Timestamp.fromDate(cert.createdAt),
          'updatedAt': Timestamp.fromDate(cert.updatedAt),
        };
      }).toList(),
      if (suspendedAt != null) 'suspendedAt': suspendedAt,
      if (suspendedBy != null) 'suspendedBy': suspendedBy,
      if (suspensionReason != null) 'suspensionReason': suspensionReason,
      if (suspendedUntil != null) 'suspendedUntil': suspendedUntil,
      if (deactivatedAt != null) 'deactivatedAt': deactivatedAt,
      if (deactivatedBy != null) 'deactivatedBy': deactivatedBy,
      if (deactivationReason != null) 'deactivationReason': deactivationReason,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data['createdAt'] = Timestamp.fromDate(createdAt);
    data['updatedAt'] = Timestamp.fromDate(updatedAt);
    if (rejectedAt != null) {
      data['rejectedAt'] = Timestamp.fromDate(rejectedAt!);
    }
    if (rejectedBy != null) {
      data['rejectedBy'] = rejectedBy;
    }
    if (suspendedAt != null) {
      data['suspendedAt'] = Timestamp.fromDate(suspendedAt!);
    }
    if (suspendedBy != null) {
      data['suspendedBy'] = suspendedBy;
    }
    if (suspensionReason != null) {
      data['suspensionReason'] = suspensionReason;
    }
    if (suspendedUntil != null) {
      data['suspendedUntil'] = Timestamp.fromDate(suspendedUntil!);
    }
    if (deactivatedAt != null) {
      data['deactivatedAt'] = Timestamp.fromDate(deactivatedAt!);
    }
    if (deactivatedBy != null) {
      data['deactivatedBy'] = deactivatedBy;
    }
    if (deactivationReason != null) {
      data['deactivationReason'] = deactivationReason;
    }
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
      priceRange: entity.priceRange,
      ratingAverage: entity.ratingAverage,
      approvalStatus: entity.approvalStatus,
      operatingHours: entity.operatingHours,
      outlets: entity.outlets,
      certifications: entity.certifications,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      rejectedAt: entity.rejectedAt,
      rejectedBy: entity.rejectedBy,
      rejectionReason: entity.rejectionReason,
      suspendedAt: entity.suspendedAt,
      suspendedBy: entity.suspendedBy,
      suspensionReason: entity.suspensionReason,
      suspendedUntil: entity.suspendedUntil,
      deactivatedAt: entity.deactivatedAt,
      deactivatedBy: entity.deactivatedBy,
      deactivationReason: entity.deactivationReason,
      latitude: entity.latitude,
      longitude: entity.longitude,
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
      priceRange: data['priceRange'],
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble(),
      approvalStatus: data['approvalStatus'] ?? 'pending',
      operatingHours: operatingHoursMap,
      outlets: _parseOutlets(data['outlets']),
      certifications: _parseCertifications(data['certifications']),
      menuItems:
          const [], // Menu items are fetched separately from subcollection
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rejectedAt: _parseTimestampNullable(data['rejectedAt']),
      rejectedBy: data['rejectedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      suspendedAt: _parseTimestampNullable(data['suspendedAt']),
      suspendedBy: data['suspendedBy'] as String?,
      suspensionReason: data['suspensionReason'] as String?,
      suspendedUntil: _parseTimestampNullable(data['suspendedUntil']),
      deactivatedAt: _parseTimestampNullable(data['deactivatedAt']),
      deactivatedBy: data['deactivatedBy'] as String?,
      deactivationReason: data['deactivationReason'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble()
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
      priceRange: priceRange,
      ratingAverage: ratingAverage,
      approvalStatus: approvalStatus,
      outlets: outlets,
      certifications: certifications,
      menuItems: menuItems.map((m) => m.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      rejectedAt: rejectedAt,
      rejectedBy: rejectedBy,
      rejectionReason: rejectionReason,
      suspendedAt: suspendedAt,
      suspendedBy: suspendedBy,
      suspensionReason: suspensionReason,
      suspendedUntil: suspendedUntil,
      deactivatedAt: deactivatedAt,
      deactivatedBy: deactivatedBy,
      deactivationReason: deactivationReason,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static DateTime? _parseTimestampNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

List<OutletEntity> _parseOutlets(dynamic raw) {
  if (raw is! List) return const <OutletEntity>[];
  final rawList = raw.cast<dynamic>();
  return rawList.map((item) {
    final data = Map<String, dynamic>.from(item as Map);
    final rawHours = data['operatingHours'] as Map<String, dynamic>? ?? {};
    final operatingHours = rawHours.map((day, value) {
      final map = Map<String, dynamic>.from(value as Map);
      return MapEntry(
        day,
        OperatingHours(
          day: day,
          openTime: map['openTime'],
          closeTime: map['closeTime'],
          isClosed: map['isClosed'] ?? false,
        ),
      );
    });
    return OutletEntity(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      cuisineType: data['cuisineType'],
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      operatingHours: operatingHours,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: _timestampToDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _timestampToDate(data['updatedAt']) ?? DateTime.now(),
    );
  }).toList();
}

List<CertificationEntity> _parseCertifications(dynamic raw) {
  if (raw is! List) return const <CertificationEntity>[];
  final rawList = raw.cast<dynamic>();
  return rawList.map((item) {
    final data = Map<String, dynamic>.from(item as Map);
    return CertificationEntity(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      certificateImageUrl: data['certificateImageUrl'],
      certificateNumber: data['certificateNumber'],
      expiryDate: _timestampToDate(data['expiryDate']),
      status: _statusFromString(data['status']),
      verifiedBy: data['verifiedBy'],
      verifiedAt: _timestampToDate(data['verifiedAt']),
      rejectionReason: data['rejectionReason'],
      createdAt: _timestampToDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _timestampToDate(data['updatedAt']) ?? DateTime.now(),
    );
  }).toList();
}

CertificationStatus _statusFromString(dynamic status) {
  switch (status) {
    case 'verified':
      return CertificationStatus.verified;
    case 'rejected':
      return CertificationStatus.rejected;
    case 'pending':
    default:
      return CertificationStatus.pending;
  }
}

DateTime? _timestampToDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
