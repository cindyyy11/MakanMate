abstract class VendorEvent {}

class LoadVendorProfileEvent extends VendorEvent {
  final String vendorId;

  LoadVendorProfileEvent(this.vendorId);
}

class LoadVendorMenuEvent extends VendorEvent {
  final String vendorId;

  LoadVendorMenuEvent(this.vendorId);
}
