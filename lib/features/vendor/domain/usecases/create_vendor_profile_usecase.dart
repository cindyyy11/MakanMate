import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_profile_repository.dart';

class CreateVendorProfileUseCase {
  final VendorProfileRepository repository;

  CreateVendorProfileUseCase(this.repository);

  Future<void> call(VendorProfileEntity profile) async {
    return await repository.createVendorProfile(profile);
  }
}

