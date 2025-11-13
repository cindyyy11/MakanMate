import '../repositories/vendor_repository.dart';
import '../entities/menu_item_entity.dart';

class AddMenuItemUseCase {
  final VendorRepository repository;
  AddMenuItemUseCase(this.repository);

  Future<void> call(MenuItemEntity item) async {
    await repository.addMenuItem(item);
  }
}
