import '../entities/menu_item_entity.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';

abstract class VendorRepository {
  Future<List<MenuItemEntity>> getMenuItems();
  Future<void> addMenuItem(MenuItemEntity item);
  Future<void> updateMenuItem(MenuItemEntity item);
  Future<void> deleteMenuItem(String id);
}
