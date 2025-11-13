import '../../domain/entities/vendor_profile_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remote;

  VendorRepositoryImpl(this.remote);

  @override
  Future<VendorProfileEntity> getVendorProfile(String vendorId) {
    return remote.getVendorProfile(vendorId);
  }

  @override
  Future<List<MenuItemEntity>> getVendorMenuItems(String vendorId) {
    return remote.getVendorMenuItems(vendorId);
  }

  @override
  Future<List<VendorProfileEntity>> getAllApprovedVendors() {
    return remote.getAllApprovedVendors();
  }
}
