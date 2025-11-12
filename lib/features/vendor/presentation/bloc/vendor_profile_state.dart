import '../../domain/entities/vendor_profile_entity.dart';

abstract class VendorProfileState {}

class VendorProfileInitial extends VendorProfileState {}

class VendorProfileLoading extends VendorProfileState {}

class VendorProfileLoaded extends VendorProfileState {
  final VendorProfileEntity profile;
  VendorProfileLoaded(this.profile);
}

class VendorProfileError extends VendorProfileState {
  final String message;
  VendorProfileError(this.message);
}

class VendorProfileUpdating extends VendorProfileState {
  final VendorProfileEntity profile;
  VendorProfileUpdating(this.profile);
}

class VendorProfileUpdated extends VendorProfileState {
  final VendorProfileEntity profile;
  VendorProfileUpdated(this.profile);
}

class ImageUploading extends VendorProfileState {
  final double? progress;
  final String type; // 'profilePhoto' or 'businessLogo'
  ImageUploading({this.progress, required this.type});
}

class ImageUploaded extends VendorProfileState {
  final String imageUrl;
  final String type; // 'profilePhoto' or 'businessLogo'
  ImageUploaded({required this.imageUrl, required this.type});
}

class ImageUploadError extends VendorProfileState {
  final String message;
  ImageUploadError(this.message);
}

