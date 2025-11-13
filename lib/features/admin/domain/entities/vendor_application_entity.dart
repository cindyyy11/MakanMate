import 'package:equatable/equatable.dart';

/// Vendor application for review
class VendorApplication extends Equatable {
  final String id;
  final String businessName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final int riskScore; // 0-100
  final List<String> redFlags;
  final ApplicationStatus status;
  final String? businessRegistrationNumber;
  final String? halalCertNumber;
  final DateTime? halalCertExpiry;
  final List<String> photoUrls;
  final List<ApplicationNote> notes;
  final String? assignedTo; // Admin ID
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  const VendorApplication({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.riskScore,
    this.redFlags = const [],
    this.status = ApplicationStatus.pending,
    this.businessRegistrationNumber,
    this.halalCertNumber,
    this.halalCertExpiry,
    this.photoUrls = const [],
    this.notes = const [],
    this.assignedTo,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  @override
  List<Object?> get props => [
        id,
        businessName,
        ownerName,
        email,
        phoneNumber,
        address,
        latitude,
        longitude,
        riskScore,
        redFlags,
        status,
        businessRegistrationNumber,
        halalCertNumber,
        halalCertExpiry,
        photoUrls,
        notes,
        assignedTo,
        submittedAt,
        reviewedAt,
        reviewedBy,
      ];
}

enum ApplicationStatus {
  pending,
  needsInfo,
  approved,
  rejected,
  escalated,
}

class ApplicationNote extends Equatable {
  final String id;
  final String note;
  final String createdBy;
  final DateTime createdAt;

  const ApplicationNote({
    required this.id,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, note, createdBy, createdAt];
}

/// Vendor rejection with feedback
class VendorRejection extends Equatable {
  final String applicationId;
  final RejectionReason reason;
  final String feedback;
  final DateTime rejectedAt;
  final String rejectedBy;

  const VendorRejection({
    required this.applicationId,
    required this.reason,
    required this.feedback,
    required this.rejectedAt,
    required this.rejectedBy,
  });

  @override
  List<Object?> get props => [
        applicationId,
        reason,
        feedback,
        rejectedAt,
        rejectedBy,
      ];
}

enum RejectionReason {
  incompleteInformation,
  invalidBusinessLicense,
  expiredHalalCert,
  duplicateListing,
  suspiciousActivity,
  other,
}

/// Request for more information
class InformationRequest extends Equatable {
  final String applicationId;
  final List<RequestedItem> requestedItems;
  final String message;
  final DateTime requestedAt;
  final String requestedBy;

  const InformationRequest({
    required this.applicationId,
    required this.requestedItems,
    required this.message,
    required this.requestedAt,
    required this.requestedBy,
  });

  @override
  List<Object?> get props => [
        applicationId,
        requestedItems,
        message,
        requestedAt,
        requestedBy,
      ];
}

enum RequestedItem {
  halalCertificate,
  businessLicense,
  menuPhotos,
  openingHours,
  locationVerification,
  other,
}

/// Halal certification verification
class HalalCertVerification extends Equatable {
  final String vendorId;
  final String certNumber;
  final String issuingAuthority; // JAKIM, etc.
  final DateTime expiryDate;
  final String businessName;
  final VerificationStatus status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;

  const HalalCertVerification({
    required this.vendorId,
    required this.certNumber,
    required this.issuingAuthority,
    required this.expiryDate,
    required this.businessName,
    this.status = VerificationStatus.pending,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        vendorId,
        certNumber,
        issuingAuthority,
        expiryDate,
        businessName,
        status,
        verifiedBy,
        verifiedAt,
        notes,
      ];
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

/// Vendor performance report
class VendorPerformanceReport extends Equatable {
  final String vendorId;
  final String vendorName;
  final int totalViews;
  final int directionClicks;
  final double conversionRate; // Percentage
  final double averageRating;
  final int totalReviews;
  final DateTime? lastMenuUpdate;
  final double responseRate; // Percentage
  final int complianceScore; // 0-100
  final DateTime generatedAt;

  const VendorPerformanceReport({
    required this.vendorId,
    required this.vendorName,
    required this.totalViews,
    required this.directionClicks,
    required this.conversionRate,
    required this.averageRating,
    required this.totalReviews,
    this.lastMenuUpdate,
    required this.responseRate,
    required this.complianceScore,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        vendorId,
        vendorName,
        totalViews,
        directionClicks,
        conversionRate,
        averageRating,
        totalReviews,
        lastMenuUpdate,
        responseRate,
        complianceScore,
        generatedAt,
      ];
}

/// Vendor suspension
class VendorSuspension extends Equatable {
  final String vendorId;
  final SuspensionDuration duration;
  final DateTime? suspendedUntil;
  final String reason;
  final DateTime suspendedAt;
  final String suspendedBy;
  final bool isPermanent;

  const VendorSuspension({
    required this.vendorId,
    required this.duration,
    this.suspendedUntil,
    required this.reason,
    required this.suspendedAt,
    required this.suspendedBy,
    this.isPermanent = false,
  });

  @override
  List<Object?> get props => [
        vendorId,
        duration,
        suspendedUntil,
        reason,
        suspendedAt,
        suspendedBy,
        isPermanent,
      ];
}

enum SuspensionDuration {
  sevenDays,
  thirtyDays,
  ninetyDays,
  permanent,
}

/// Vendor compliance alert
class VendorComplianceAlert extends Equatable {
  final String id;
  final String vendorId;
  final String vendorName;
  final ComplianceIssueType issueType;
  final String message;
  final DateTime? dueDate;
  final AlertPriority priority;
  final bool isResolved;
  final DateTime createdAt;

  const VendorComplianceAlert({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.issueType,
    required this.message,
    this.dueDate,
    this.priority = AlertPriority.medium,
    this.isResolved = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        vendorName,
        issueType,
        message,
        dueDate,
        priority,
        isResolved,
        createdAt,
      ];
}

enum ComplianceIssueType {
  halalCertExpiring,
  staleMenuData,
  lowResponseRate,
  photoQuality,
  locationInaccuracy,
  other,
}

enum AlertPriority {
  low,
  medium,
  high,
}

/// Duplicate vendor detection
class DuplicateVendor extends Equatable {
  final String id;
  final String vendor1Id;
  final String vendor1Name;
  final String vendor2Id;
  final String vendor2Name;
  final double distance; // meters
  final double nameSimilarity; // 0-1
  final DuplicateStatus status;
  final DateTime detectedAt;

  const DuplicateVendor({
    required this.id,
    required this.vendor1Id,
    required this.vendor1Name,
    required this.vendor2Id,
    required this.vendor2Name,
    required this.distance,
    required this.nameSimilarity,
    this.status = DuplicateStatus.pending,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vendor1Id,
        vendor1Name,
        vendor2Id,
        vendor2Name,
        distance,
        nameSimilarity,
        status,
        detectedAt,
      ];
}

enum DuplicateStatus {
  pending,
  merged,
  keptSeparate,
  markedAsDuplicate,
}


