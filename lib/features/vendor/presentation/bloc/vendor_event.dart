import 'dart:io';
import '../../../vendor/domain/entities/menu_item_entity.dart';

abstract class VendorEvent {}

class LoadMenuEvent extends VendorEvent {}

class SearchMenuEvent extends VendorEvent {
  final String query;
  SearchMenuEvent(this.query);
}

class FilterByCategoryEvent extends VendorEvent {
  final String? category; // null means "All"
  FilterByCategoryEvent(this.category);
}

class UploadImageEvent extends VendorEvent {
  final File imageFile;
  UploadImageEvent(this.imageFile);
}

class AddMenuEvent extends VendorEvent {
  final MenuItemEntity item;
  final File? imageFile; // Optional image file to upload
  AddMenuEvent(this.item, {this.imageFile});
}

class UpdateMenuEvent extends VendorEvent {
  final MenuItemEntity item;
  final File? imageFile; // Optional image file to upload
  UpdateMenuEvent(this.item, {this.imageFile});
}

class DeleteMenuEvent extends VendorEvent {
  final String id;
  DeleteMenuEvent(this.id);
}
