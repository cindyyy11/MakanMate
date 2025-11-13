import '../entities/vendor_profile_entity.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_profile_repository.dart';

class GetAllApprovedVendorsUseCase {
  final VendorProfileRepository repository;

  GetAllApprovedVendorsUseCase(this.repository);

  Future<List<VendorProfileEntity>> call() {
    return repository.getAllApprovedVendors();
  }
}
