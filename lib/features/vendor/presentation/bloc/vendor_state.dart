import '../../../vendor/domain/entities/menu_item_entity.dart';

abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final List<MenuItemEntity> menu;
  final List<MenuItemEntity> filteredMenu; // Filtered/search results
  final String? selectedCategory;
  final String searchQuery;
  
  VendorLoaded(
    this.menu, {
    List<MenuItemEntity>? filteredMenu,
    this.selectedCategory,
    this.searchQuery = '',
  }) : filteredMenu = filteredMenu ?? menu;
}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
}

// Image upload states
class ImageUploading extends VendorState {
  final double? progress;
  ImageUploading({this.progress});
}

class ImageUploaded extends VendorState {
  final String imageUrl;
  ImageUploaded(this.imageUrl);
}

class ImageUploadError extends VendorState {
  final String message;
  ImageUploadError(this.message);
}
