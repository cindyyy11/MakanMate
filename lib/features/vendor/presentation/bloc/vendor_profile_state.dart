import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_profile_entity.dart';

abstract class VendorProfileState extends Equatable {
  const VendorProfileState();

  @override
  List<Object?> get props => [];
}

class VendorProfileInitial extends VendorProfileState {
  const VendorProfileInitial();
}

class VendorProfileLoading extends VendorProfileState {
  const VendorProfileLoading();
}

abstract class VendorProfileReadyState extends VendorProfileState {
  const VendorProfileReadyState(this.profile);

  final VendorProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class VendorProfileLoaded extends VendorProfileReadyState {
  const VendorProfileLoaded(super.profile);
}

class VendorPendingApprovalState extends VendorProfileReadyState {
  const VendorPendingApprovalState(super.profile);
}

class VendorRejectedState extends VendorProfileReadyState {
  const VendorRejectedState(
    super.profile, {
    this.reason,
  });

  final String? reason;

  @override
  List<Object?> get props => [profile, reason];
}

class VendorProfileError extends VendorProfileState {
  const VendorProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class VendorProfileUpdating extends VendorProfileReadyState {
  const VendorProfileUpdating(super.profile);
}

class VendorProfileUpdated extends VendorProfileReadyState {
  const VendorProfileUpdated(super.profile);
}

class ImageUploading extends VendorProfileState {
  const ImageUploading({
    this.progress,
    required this.type,
  });

  final double? progress;
  final String type;

  @override
  List<Object?> get props => [progress, type];
}

class ImageUploaded extends VendorProfileState {
  const ImageUploaded({
    required this.imageUrl,
    required this.type,
  });

  final String imageUrl;
  final String type;

  @override
  List<Object?> get props => [imageUrl, type];
}

class ImageUploadError extends VendorProfileState {
  const ImageUploadError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}



