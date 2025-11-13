import '../entities/vendor_profile_entity.dart';

abstract class VendorProfileRepository {
  Future<VendorProfileEntity?> getVendorProfile();
  Future<void> createVendorProfile(VendorProfileEntity profile);
  Future<void> updateVendorProfile(VendorProfileEntity profile);
  Future<void> updateApprovalStatus(String vendorId, String status);
}

