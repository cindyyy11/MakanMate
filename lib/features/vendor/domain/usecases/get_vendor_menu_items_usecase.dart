import '../entities/vendor_profile_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorMenuItemsUseCase {
  final VendorRepository repository;

  GetVendorMenuItemsUseCase(this.repository);

  Future<List<MenuItemEntity>> call(String vendorId) {
    return repository.getVendorMenuItems(vendorId);
  }
}
