import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/vendor/data/models/vendor_application_model.dart';

/// Remote data source interface for vendor applications
abstract class VendorRemoteDataSource {
  /// Create vendor application
  Future<VendorApplicationModel> createVendorApplication({
    required String userId,
    required String userName,
    required String email,
    required String businessName,
    required String businessType,
    String? businessDescription,
    String? phoneNumber,
    String? address,
    Map<String, dynamic>? additionalData,
  });

  /// Get vendor application by ID
  Future<VendorApplicationModel> getVendorApplication(String applicationId);

  /// Get vendor application by user ID
  Future<VendorApplicationModel?> getVendorApplicationByUserId(String userId);

  /// Approve vendor application
  Future<void> approveVendorApplication({
    required String applicationId,
    required String userId,
  });

  /// Reject vendor application
  Future<void> rejectVendorApplication({
    required String applicationId,
    required String reason,
  });
}

/// Implementation of VendorRemoteDataSource
class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String vendorApplicationsCollection = 'vendor_applications';
  static const String vendorsCollection = 'vendors';

  VendorRemoteDataSourceImpl({required this.firestore});

  @override
  Future<VendorApplicationModel> createVendorApplication({
    required String userId,
    required String userName,
    required String email,
    required String businessName,
    required String businessType,
    String? businessDescription,
    String? phoneNumber,
    String? address,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final docRef = await firestore.collection(vendorApplicationsCollection).add({
        'userId': userId,
        'userName': userName,
        'email': email,
        'businessName': businessName,
        'businessType': businessType,
        'businessDescription': businessDescription,
        'phoneNumber': phoneNumber,
        'address': address,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'additionalData': additionalData ?? {},
      });

      final doc = await docRef.get();
      return VendorApplicationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create vendor application: $e');
    }
  }

  @override
  Future<VendorApplicationModel> getVendorApplication(String applicationId) async {
    try {
      final doc = await firestore
          .collection(vendorApplicationsCollection)
          .doc(applicationId)
          .get();

      if (!doc.exists) {
        throw ServerException('Vendor application not found: $applicationId');
      }

      return VendorApplicationModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get vendor application: $e');
    }
  }

  @override
  Future<VendorApplicationModel?> getVendorApplicationByUserId(String userId) async {
    try {
      final query = await firestore
          .collection(vendorApplicationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return VendorApplicationModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw ServerException('Failed to get vendor application by user ID: $e');
    }
  }

  @override
  Future<void> approveVendorApplication({
    required String applicationId,
    required String userId,
  }) async {
    try {
      // Update application status
      await firestore
          .collection(vendorApplicationsCollection)
          .doc(applicationId)
          .update({
            'status': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
          });

      // Get application data
      final applicationDoc = await firestore
          .collection(vendorApplicationsCollection)
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) {
        throw ServerException('Vendor application not found: $applicationId');
      }

      final data = applicationDoc.data()!;

      // Create vendor document
      await firestore.collection(vendorsCollection).doc(userId).set({
        'userId': userId,
        'businessName': data['businessName'],
        'businessType': data['businessType'],
        'businessDescription': data['businessDescription'],
        'phoneNumber': data['phoneNumber'],
        'address': data['address'],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to approve vendor application: $e');
    }
  }

  @override
  Future<void> rejectVendorApplication({
    required String applicationId,
    required String reason,
  }) async {
    try {
      await firestore
          .collection(vendorApplicationsCollection)
          .doc(applicationId)
          .update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectionReason': reason,
          });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to reject vendor application: $e');
    }
  }
}

