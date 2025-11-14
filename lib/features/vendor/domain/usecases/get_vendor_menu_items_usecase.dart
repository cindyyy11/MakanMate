import '../repositories/vendor_repository.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';

class GetVendorMenuItemsUseCase {
  final VendorRepository repository;

  GetVendorMenuItemsUseCase(this.repository);

  Future<List<MenuItemEntity>> call() {
    return repository.getMenuItems();
  }
}
