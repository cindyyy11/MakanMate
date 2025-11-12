import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_profile_repository.dart';

class UpdateVendorProfileUseCase {
  final VendorProfileRepository repository;

  UpdateVendorProfileUseCase(this.repository);

  Future<void> call(VendorProfileEntity profile) async {
    return await repository.updateVendorProfile(profile);
  }
}

