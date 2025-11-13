import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_profile_model.dart';

abstract class VendorProfileRemoteDataSource {
  Future<VendorProfileModel?> getVendorProfile(String vendorId);
  Future<void> createVendorProfile(String vendorId, VendorProfileModel profile);
  Future<void> updateVendorProfile(String vendorId, VendorProfileModel profile);
  Future<void> updateApprovalStatus(String vendorId, String status);
  Future<List<VendorProfileModel>> getAllApprovedVendors();
}

class VendorProfileRemoteDataSourceImpl
    implements VendorProfileRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<VendorProfileModel?> getVendorProfile(String vendorId) async {
    try {
      final doc = await firestore.collection('vendors').doc(vendorId).get();
      if (doc.exists) {
        return VendorProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vendor profile: $e');
    }
  }

  @override
  Future<void> createVendorProfile(
    String vendorId,
    VendorProfileModel profile,
  ) async {
    try {
      final data = profile.toFirestore();
      data['approvalStatus'] = data['approvalStatus'] ?? 'pending';
      await firestore.collection('vendors').doc(vendorId).set(data);
    } catch (e) {
      throw Exception('Failed to create vendor profile: $e');
    }
  }

  @override
  Future<void> updateVendorProfile(
    String vendorId,
    VendorProfileModel profile,
  ) async {
    try {
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update vendor profile: $e');
    }
  }

  @override
  Future<void> updateApprovalStatus(String vendorId, String status) async {
    try {
      await firestore.collection('vendors').doc(vendorId).update({
        'approvalStatus': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update approval status: $e');
    }
  }

  @override
  Future<List<VendorProfileModel>> getAllApprovedVendors() async {
    try {
      final querySnapshot = await firestore
          .collection('vendors')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      return querySnapshot.docs
          .map((doc) => VendorProfileModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all approved vendors: $e');
    }
  }
}
