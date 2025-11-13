import '../../domain/entities/vendor_profile_entity.dart';

abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final VendorProfileEntity vendor;
  final List<MenuItemEntity> menuItems;

  VendorLoaded({
    required this.vendor,
    required this.menuItems,
  });
}

class VendorError extends VendorState {
  final String message;

  VendorError(this.message);
}
