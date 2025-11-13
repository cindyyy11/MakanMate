import '../repositories/vendor_repository.dart';
import '../entities/menu_item_entity.dart';

class UpdateMenuItemUseCase {
  final VendorRepository repository;
  UpdateMenuItemUseCase(this.repository);

  Future<void> call(MenuItemEntity item) async {
    await repository.updateMenuItem(item);
  }
}
