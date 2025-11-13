import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_application_entity.dart';

/// Vendor application data model (Data layer)
class VendorApplicationModel extends VendorApplicationEntity {
  const VendorApplicationModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.email,
    required super.businessName,
    required super.businessType,
    required super.cuisineType,
    super.businessDescription,
    super.phoneNumber,
    super.address,
    super.status,
    required super.submittedAt,
    super.approvedAt,
    super.rejectedAt,
    super.rejectionReason,
    super.additionalData,
  });

  /// Create VendorApplicationModel from Firestore document
  factory VendorApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorApplicationModel(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      email: data['email'] as String,
      businessName: data['businessName'] as String,
      businessType: data['businessType'] as String,
      cuisineType: data['cuisineType'] as String,
      businessDescription: data['businessDescription'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      address: data['address'] as String?,
      status: data['status'] as String? ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      rejectedAt: data['rejectedAt'] != null
          ? (data['rejectedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason'] as String?,
      additionalData: Map<String, dynamic>.from(data['additionalData'] ?? {}),
    );
  }

  /// Convert VendorApplicationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'businessName': businessName,
      'businessType': businessType,
      'cuisineType': cuisineType,
      'businessDescription': businessDescription,
      'phoneNumber': phoneNumber,
      'address': address,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectionReason': rejectionReason,
      'additionalData': additionalData,
    };
  }
}
