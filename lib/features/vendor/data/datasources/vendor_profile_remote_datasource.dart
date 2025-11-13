import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_profile_model.dart';

abstract class VendorProfileRemoteDataSource {
  Future<VendorProfileModel?> getVendorProfile(String vendorId);
  Future<void> createVendorProfile(String vendorId, VendorProfileModel profile);
  Future<void> updateVendorProfile(String vendorId, VendorProfileModel profile);
}

class VendorProfileRemoteDataSourceImpl implements VendorProfileRemoteDataSource {
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
  Future<void> createVendorProfile(String vendorId, VendorProfileModel profile) async {
    try {
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .set(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to create vendor profile: $e');
    }
  }

  @override
  Future<void> updateVendorProfile(String vendorId, VendorProfileModel profile) async {
    try {
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update vendor profile: $e');
    }
  }
}

