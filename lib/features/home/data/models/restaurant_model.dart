import '../../../vendor/data/models/vendor_profile_model.dart';
import '../../../vendor/data/models/menu_item_model.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel {
  final VendorProfileModel vendorModel;
  final List<MenuItemModel> menuItemModels;

  RestaurantModel({
    required this.vendorModel,
    required this.menuItemModels,
  });

  RestaurantEntity toEntity() {
    return RestaurantEntity(
      vendor: vendorModel.toEntity(),
      menuItems: menuItemModels.map((m) => m.toEntity()).toList(),
      cuisine: vendorModel.cuisine,
      priceRange: vendorModel.priceRange,
      ratingAverage: vendorModel.ratingAverage,
    );
  }
}
