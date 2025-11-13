import '../entities/vendor_profile_entity.dart';

abstract class VendorRepository {
  Future<VendorProfileEntity> getVendorProfile(String vendorId);
  Future<List<MenuItemEntity>> getVendorMenuItems(String vendorId);
  Future<List<VendorProfileEntity>> getAllApprovedVendors();
}
