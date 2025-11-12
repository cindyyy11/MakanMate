import 'dart:io';
import '../../domain/entities/vendor_profile_entity.dart';

abstract class VendorProfileEvent {}

class LoadVendorProfileEvent extends VendorProfileEvent {}

class UpdateVendorProfileEvent extends VendorProfileEvent {
  final VendorProfileEntity profile;
  UpdateVendorProfileEvent(this.profile);
}

class UploadProfilePhotoEvent extends VendorProfileEvent {
  final File imageFile;
  UploadProfilePhotoEvent(this.imageFile);
}


class AddOutletEvent extends VendorProfileEvent {
  final OutletEntity outlet;
  AddOutletEvent(this.outlet);
}

class UpdateOutletEvent extends VendorProfileEvent {
  final OutletEntity outlet;
  UpdateOutletEvent(this.outlet);
}

class DeleteOutletEvent extends VendorProfileEvent {
  final String outletId;
  DeleteOutletEvent(this.outletId);
}

class AddCertificationEvent extends VendorProfileEvent {
  final CertificationEntity certification;
  final File? certificateImageFile;
  AddCertificationEvent(this.certification, {this.certificateImageFile});
}

class UpdateCertificationEvent extends VendorProfileEvent {
  final CertificationEntity certification;
  final File? certificateImageFile;
  UpdateCertificationEvent(this.certification, {this.certificateImageFile});
}

class DeleteCertificationEvent extends VendorProfileEvent {
  final String certificationId;
  DeleteCertificationEvent(this.certificationId);
}

class UploadCertificateImageEvent extends VendorProfileEvent {
  final File imageFile;
  final String certificationId;
  UploadCertificateImageEvent(this.imageFile, this.certificationId);
}

class VerifyCertificationEvent extends VendorProfileEvent {
  final String certificationId;
  final String adminUserId;
  VerifyCertificationEvent(this.certificationId, this.adminUserId);
}

class RejectCertificationEvent extends VendorProfileEvent {
  final String certificationId;
  final String adminUserId;
  final String reason;
  RejectCertificationEvent(this.certificationId, this.adminUserId, this.reason);
}

