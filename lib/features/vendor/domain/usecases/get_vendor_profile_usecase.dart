import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_profile_repository.dart';

class GetVendorProfileUseCase {
  final VendorProfileRepository repository;

  GetVendorProfileUseCase(this.repository);

  Future<VendorProfileEntity?> call() async {
    return await repository.getVendorProfile();
  }
}

