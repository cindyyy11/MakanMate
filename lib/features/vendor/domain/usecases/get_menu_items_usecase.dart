import '../repositories/vendor_repository.dart';
import '../entities/menu_item_entity.dart';

class GetMenuItemsUseCase {
  final VendorRepository repository;
  GetMenuItemsUseCase(this.repository);

  Future<List<MenuItemEntity>> call() async {
    return await repository.getMenuItems();
  }
}
