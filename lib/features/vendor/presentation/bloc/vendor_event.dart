import 'dart:io';
import '../../../vendor/domain/entities/menu_item_entity.dart';

abstract class VendorEvent {}

// Menu Events
class LoadMenuEvent extends VendorEvent {}

class SearchMenuEvent extends VendorEvent {
  final String query;
  SearchMenuEvent(this.query);
}

class FilterByCategoryEvent extends VendorEvent {
  final String? category;
  FilterByCategoryEvent(this.category);
}

class UploadImageEvent extends VendorEvent {
  final File imageFile;
  UploadImageEvent(this.imageFile);
}

class AddMenuEvent extends VendorEvent {
  final MenuItemEntity item;
  final File? imageFile;
  AddMenuEvent(this.item, {this.imageFile});
}

class UpdateMenuEvent extends VendorEvent {
  final MenuItemEntity item;
  final File? imageFile;
  UpdateMenuEvent(this.item, {this.imageFile});
}

class DeleteMenuEvent extends VendorEvent {
  final String id;
  DeleteMenuEvent(this.id);
}
