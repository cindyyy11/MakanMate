import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_repository.dart';

class GetAllApprovedVendorsUseCase {
  final VendorRepository repository;

  GetAllApprovedVendorsUseCase(this.repository);

  Future<List<VendorProfileEntity>> call() {
    return repository.getAllApprovedVendors();
  }
}
