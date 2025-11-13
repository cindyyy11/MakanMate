import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vendor_profile_entity.dart';

class VendorProfileModel {
  final String id;
  final String? profilePhotoUrl;
  final String? businessLogoUrl;
  final String? bannerImageUrl;
  final String businessName;
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

  factory VendorProfileModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return VendorProfileModel(
      id: id,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      businessLogoUrl: data['businessLogoUrl'] as String?,
      businessName: data['businessName'] as String? ?? '',
      bannerImageUrl: data['bannerImageUrl'] as String ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      emailAddress: data['emailAddress'] as String? ?? '',
      businessAddress: data['businessAddress'] as String? ?? '',
      operatingHours: (data['operatingHours'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value as Map<String, dynamic>)),
      shortDescription: data['shortDescription'] as String? ?? '',
      outlets: (data['outlets'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      certifications: (data['certifications'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      approvalStatus: data['approvalStatus'] as String? ?? 'pending',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  factory VendorProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorProfileModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'businessLogoUrl': businessLogoUrl,
      'businessName': businessName,
      'bannerImageUrl': bannerImageUrl,
      'contactNumber': contactNumber,
      'emailAddress': emailAddress,
      'businessAddress': businessAddress,
      'operatingHours': operatingHours,
      'shortDescription': shortDescription,
      'outlets': outlets,
      'certifications': certifications,
      'approvalStatus': approvalStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data['createdAt'] = Timestamp.fromDate(createdAt);
    data['updatedAt'] = Timestamp.fromDate(updatedAt);
    return data;
  }

  VendorProfileEntity toEntity() {
    return VendorProfileEntity(
      id: id,
      profilePhotoUrl: profilePhotoUrl,
      businessLogoUrl: businessLogoUrl,
      bannerImageUrl: bannerImageUrl,
      businessName: businessName,
      contactNumber: contactNumber,
      emailAddress: emailAddress,
      businessAddress: businessAddress,
      operatingHours: operatingHours.map((key, value) => MapEntry(
            key,
            OperatingHours(
              day: key,
              openTime: value['openTime'] as String?,
              closeTime: value['closeTime'] as String?,
              isClosed: value['isClosed'] as bool? ?? false,
            ),
          )),
      shortDescription: shortDescription,
      outlets: outlets.map((outlet) {
        return OutletEntity(
          id: outlet['id'] as String? ?? '',
          name: outlet['name'] as String? ?? '',
          address: outlet['address'] as String? ?? '',
          contactNumber: outlet['contactNumber'] as String? ?? '',
          operatingHours: (outlet['operatingHours'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(
                    key,
                    OperatingHours(
                      day: key,
                      openTime: value['openTime'] as String?,
                      closeTime: value['closeTime'] as String?,
                      isClosed: value['isClosed'] as bool? ?? false,
                    ),
                  )),
          latitude: (outlet['latitude'] as num?)?.toDouble(),
          longitude: (outlet['longitude'] as num?)?.toDouble(),
          createdAt: (outlet['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (outlet['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList(),
      certifications: certifications.map((cert) {
        return CertificationEntity(
          id: cert['id'] as String? ?? '',
          type: cert['type'] as String? ?? '',
          certificateImageUrl: cert['certificateImageUrl'] as String?,
          certificateNumber: cert['certificateNumber'] as String?,
          expiryDate: (cert['expiryDate'] as Timestamp?)?.toDate(),
          status: _parseCertificationStatus(cert['status'] as String?),
          verifiedBy: cert['verifiedBy'] as String?,
          verifiedAt: (cert['verifiedAt'] as Timestamp?)?.toDate(),
          rejectionReason: cert['rejectionReason'] as String?,
          createdAt: (cert['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (cert['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList(),
      approvalStatus: approvalStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static VendorProfileModel fromEntity(VendorProfileEntity entity) {
    return VendorProfileModel(
      id: entity.id,
      profilePhotoUrl: entity.profilePhotoUrl,
      businessLogoUrl: entity.businessLogoUrl,
      bannerImageUrl: entity.bannerImageUrl,
      businessName: entity.businessName,
      contactNumber: entity.contactNumber,
      emailAddress: entity.emailAddress,
      businessAddress: entity.businessAddress,
      operatingHours: entity.operatingHours.map((key, value) => MapEntry(
            key,
            {
              'openTime': value.openTime,
              'closeTime': value.closeTime,
              'isClosed': value.isClosed,
            },
          )),
      shortDescription: entity.shortDescription,
      outlets: entity.outlets.map((outlet) {
        return {
          'id': outlet.id,
          'name': outlet.name,
          'address': outlet.address,
          'contactNumber': outlet.contactNumber,
          'operatingHours': outlet.operatingHours.map((key, value) => MapEntry(
                key,
                {
                  'openTime': value.openTime,
                  'closeTime': value.closeTime,
                  'isClosed': value.isClosed,
                },
              )).cast<String, dynamic>(),
          'latitude': outlet.latitude,
          'longitude': outlet.longitude,
          'createdAt': Timestamp.fromDate(outlet.createdAt),
          'updatedAt': Timestamp.fromDate(outlet.updatedAt),
        };
      }).toList(),
      certifications: entity.certifications.map((cert) {
        return {
          'id': cert.id,
          'type': cert.type,
          'certificateImageUrl': cert.certificateImageUrl,
          'certificateNumber': cert.certificateNumber,
          'expiryDate': cert.expiryDate != null ? Timestamp.fromDate(cert.expiryDate!) : null,
          'status': cert.status.name,
          'verifiedBy': cert.verifiedBy,
          'verifiedAt': cert.verifiedAt != null ? Timestamp.fromDate(cert.verifiedAt!) : null,
          'rejectionReason': cert.rejectionReason,
          'createdAt': Timestamp.fromDate(cert.createdAt),
          'updatedAt': Timestamp.fromDate(cert.updatedAt),
        };
      }).toList(),
      approvalStatus: entity.approvalStatus,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static CertificationStatus _parseCertificationStatus(String? status) {
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

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}

