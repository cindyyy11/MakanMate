import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorProfileUseCase {
  final VendorRepository repository;

  GetVendorProfileUseCase(this.repository);

  Future<VendorProfileEntity> call(String vendorId) {
    return repository.getVendorProfile(vendorId);
  }
}
