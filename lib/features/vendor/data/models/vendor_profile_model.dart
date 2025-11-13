import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vendor_profile_entity.dart';

class VendorProfileModel {
  final String id;
  final String? profilePhotoUrl;
  final String? businessLogoUrl;
  final String businessName;
  final String contactNumber;
  final String emailAddress;
  final String businessAddress;
  final Map<String, Map<String, dynamic>> operatingHours;
  final String shortDescription;
  final List<Map<String, dynamic>> outlets;
  final List<Map<String, dynamic>> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorProfileModel({
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

  factory VendorProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorProfileModel(
      id: doc.id,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      businessLogoUrl: data['businessLogoUrl'] as String?,
      businessName: data['businessName'] as String? ?? '',
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'businessLogoUrl': businessLogoUrl,
      'businessName': businessName,
      'contactNumber': contactNumber,
      'emailAddress': emailAddress,
      'businessAddress': businessAddress,
      'operatingHours': operatingHours,
      'shortDescription': shortDescription,
      'outlets': outlets,
      'certifications': certifications,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  VendorProfileEntity toEntity() {
    return VendorProfileEntity(
      id: id,
      profilePhotoUrl: profilePhotoUrl,
      businessLogoUrl: businessLogoUrl,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static VendorProfileModel fromEntity(VendorProfileEntity entity) {
    return VendorProfileModel(
      id: entity.id,
      profilePhotoUrl: entity.profilePhotoUrl,
      businessLogoUrl: entity.businessLogoUrl,
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
}

