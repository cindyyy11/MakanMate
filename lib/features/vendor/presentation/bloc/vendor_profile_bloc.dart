import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vendor_profile_event.dart';
import 'vendor_profile_state.dart';
import '../../../vendor/domain/usecases/get_vendor_profile_usecase.dart';
import '../../../vendor/domain/usecases/update_vendor_profile_usecase.dart';
import '../../../vendor/domain/usecases/create_vendor_profile_usecase.dart';
import '../../../vendor/data/services/storage_service.dart';
import '../../../vendor/domain/entities/vendor_profile_entity.dart';

class VendorProfileBloc extends Bloc<VendorProfileEvent, VendorProfileState> {
  final GetVendorProfileUseCase getVendorProfile;
  final UpdateVendorProfileUseCase updateVendorProfile;
  final CreateVendorProfileUseCase createVendorProfile;
  final StorageService storageService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VendorProfileBloc({
    required this.getVendorProfile,
    required this.updateVendorProfile,
    required this.createVendorProfile,
    required this.storageService,
  }) : super(VendorProfileInitial()) {
    on<LoadVendorProfileEvent>(_onLoadVendorProfile);
    on<UpdateVendorProfileEvent>(_onUpdateVendorProfile);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);
    on<AddOutletEvent>(_onAddOutlet);
    on<UpdateOutletEvent>(_onUpdateOutlet);
    on<DeleteOutletEvent>(_onDeleteOutlet);
    on<AddCertificationEvent>(_onAddCertification);
    on<UpdateCertificationEvent>(_onUpdateCertification);
    on<DeleteCertificationEvent>(_onDeleteCertification);
    on<UploadCertificateImageEvent>(_onUploadCertificateImage);
    on<VerifyCertificationEvent>(_onVerifyCertification);
    on<RejectCertificationEvent>(_onRejectCertification);
  }

  Future<void> _onLoadVendorProfile(
      LoadVendorProfileEvent event, Emitter<VendorProfileState> emit) async {
    emit(VendorProfileLoading());
    try {
      final profile = await getVendorProfile();
      if (profile != null) {
        emit(VendorProfileLoaded(profile));
      } else {
        // Create default profile if it doesn't exist
        final user = _auth.currentUser;
        if (user != null) {
          final defaultProfile = VendorProfileEntity(
            id: user.uid,
            businessName: '',
            contactNumber: '',
            emailAddress: user.email ?? '',
            businessAddress: '',
            operatingHours: _getDefaultOperatingHours(),
            shortDescription: '',
            outlets: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await createVendorProfile(defaultProfile);
          emit(VendorProfileLoaded(defaultProfile));
        } else {
          emit(VendorProfileError('User not authenticated'));
        }
      }
    } catch (e) {
      emit(VendorProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateVendorProfile(
      UpdateVendorProfileEvent event, Emitter<VendorProfileState> emit) async {
    emit(VendorProfileUpdating(event.profile));
    try {
      final updatedProfile = event.profile.copyWith(updatedAt: DateTime.now());
      await updateVendorProfile(updatedProfile);
      emit(VendorProfileUpdated(updatedProfile));
      emit(VendorProfileLoaded(updatedProfile));
    } catch (e) {
      emit(VendorProfileError('Failed to update profile: $e'));
      // Re-emit the loaded state with the previous profile
      if (state is VendorProfileLoaded) {
        emit(state);
      }
    }
  }

  Future<void> _onUploadProfilePhoto(
      UploadProfilePhotoEvent event, Emitter<VendorProfileState> emit) async {
    emit(ImageUploading(type: 'profilePhoto'));
    try {
      final imageUrl = await storageService.uploadProfilePhoto(event.imageFile);
      emit(ImageUploaded(imageUrl: imageUrl, type: 'profilePhoto'));
      
      // Update profile with new photo URL
      if (state is VendorProfileLoaded) {
        final currentProfile = (state as VendorProfileLoaded).profile;
        final updatedProfile = currentProfile.copyWith(
          profilePhotoUrl: imageUrl,
          updatedAt: DateTime.now(),
        );
        add(UpdateVendorProfileEvent(updatedProfile));
      }
    } catch (e) {
      emit(ImageUploadError('Failed to upload profile photo: $e'));
    }
  }


  Future<void> _onAddOutlet(
      AddOutletEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedOutlets = [...currentProfile.outlets, event.outlet];
      final updatedProfile = currentProfile.copyWith(
        outlets: updatedOutlets,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onUpdateOutlet(
      UpdateOutletEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedOutlets = currentProfile.outlets.map((outlet) {
        return outlet.id == event.outlet.id ? event.outlet : outlet;
      }).toList();
      final updatedProfile = currentProfile.copyWith(
        outlets: updatedOutlets,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onDeleteOutlet(
      DeleteOutletEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedOutlets = currentProfile.outlets
          .where((outlet) => outlet.id != event.outletId)
          .toList();
      final updatedProfile = currentProfile.copyWith(
        outlets: updatedOutlets,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Map<String, OperatingHours> _getDefaultOperatingHours() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return Map.fromEntries(
      days.map((day) => MapEntry(day, OperatingHours(day: day, isClosed: false))),
    );
  }

  Future<void> _onAddCertification(
      AddCertificationEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      String? imageUrl = event.certification.certificateImageUrl;

      // Upload image if provided
      if (event.certificateImageFile != null) {
        try {
          imageUrl = await storageService.uploadCertificateImage(
            event.certificateImageFile!,
            event.certification.id,
          );
        } catch (e) {
          emit(VendorProfileError('Failed to upload certificate image: $e'));
          return;
        }
      }

      final certificationWithImage = event.certification.copyWith(
        certificateImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final updatedCertifications = [...currentProfile.certifications, certificationWithImage];
      final updatedProfile = currentProfile.copyWith(
        certifications: updatedCertifications,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onUpdateCertification(
      UpdateCertificationEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      String? imageUrl = event.certification.certificateImageUrl;

      // Upload new image if provided
      if (event.certificateImageFile != null) {
        try {
          imageUrl = await storageService.uploadCertificateImage(
            event.certificateImageFile!,
            event.certification.id,
          );
        } catch (e) {
          emit(VendorProfileError('Failed to upload certificate image: $e'));
          return;
        }
      }

      final certificationWithImage = event.certification.copyWith(
        certificateImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final updatedCertifications = currentProfile.certifications.map((cert) {
        return cert.id == certificationWithImage.id ? certificationWithImage : cert;
      }).toList();

      final updatedProfile = currentProfile.copyWith(
        certifications: updatedCertifications,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onDeleteCertification(
      DeleteCertificationEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedCertifications = currentProfile.certifications
          .where((cert) => cert.id != event.certificationId)
          .toList();
      final updatedProfile = currentProfile.copyWith(
        certifications: updatedCertifications,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onUploadCertificateImage(
      UploadCertificateImageEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      try {
        final imageUrl = await storageService.uploadCertificateImage(
          event.imageFile,
          event.certificationId,
        );

        final currentProfile = (state as VendorProfileLoaded).profile;
        final updatedCertifications = currentProfile.certifications.map((cert) {
          if (cert.id == event.certificationId) {
            return cert.copyWith(
              certificateImageUrl: imageUrl,
              updatedAt: DateTime.now(),
            );
          }
          return cert;
        }).toList();

        final updatedProfile = currentProfile.copyWith(
          certifications: updatedCertifications,
          updatedAt: DateTime.now(),
        );
        add(UpdateVendorProfileEvent(updatedProfile));
      } catch (e) {
        emit(VendorProfileError('Failed to upload certificate image: $e'));
      }
    }
  }

  Future<void> _onVerifyCertification(
      VerifyCertificationEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedCertifications = currentProfile.certifications.map((cert) {
        if (cert.id == event.certificationId) {
          return cert.copyWith(
            status: CertificationStatus.verified,
            verifiedBy: event.adminUserId,
            verifiedAt: DateTime.now(),
            rejectionReason: null,
            updatedAt: DateTime.now(),
          );
        }
        return cert;
      }).toList();

      final updatedProfile = currentProfile.copyWith(
        certifications: updatedCertifications,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }

  Future<void> _onRejectCertification(
      RejectCertificationEvent event, Emitter<VendorProfileState> emit) async {
    if (state is VendorProfileLoaded) {
      final currentProfile = (state as VendorProfileLoaded).profile;
      final updatedCertifications = currentProfile.certifications.map((cert) {
        if (cert.id == event.certificationId) {
          return cert.copyWith(
            status: CertificationStatus.rejected,
            verifiedBy: event.adminUserId,
            verifiedAt: DateTime.now(),
            rejectionReason: event.reason,
            updatedAt: DateTime.now(),
          );
        }
        return cert;
      }).toList();

      final updatedProfile = currentProfile.copyWith(
        certifications: updatedCertifications,
        updatedAt: DateTime.now(),
      );
      add(UpdateVendorProfileEvent(updatedProfile));
    }
  }
}

