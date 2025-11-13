import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/vendor_profile_entity.dart';
import '../../domain/repositories/vendor_profile_repository.dart';
import '../datasources/vendor_profile_remote_datasource.dart';
import '../models/vendor_profile_model.dart';

class VendorProfileRepositoryImpl implements VendorProfileRepository {
  final VendorProfileRemoteDataSource remoteDataSource;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VendorProfileRepositoryImpl({required this.remoteDataSource});

  String get vendorId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please log in.');
    }
    return user.uid;
  }

  @override
  Future<VendorProfileEntity?> getVendorProfile() async {
    try {
      final model = await remoteDataSource.getVendorProfile(vendorId);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get vendor profile: $e');
    }
  }

  @override
  Future<void> createVendorProfile(VendorProfileEntity profile) async {
    try {
      final model = VendorProfileModel.fromEntity(profile);
      await remoteDataSource.createVendorProfile(vendorId, model);
    } catch (e) {
      throw Exception('Failed to create vendor profile: $e');
    }
  }

  @override
  Future<void> updateVendorProfile(VendorProfileEntity profile) async {
    try {
      final model = VendorProfileModel.fromEntity(profile);
      await remoteDataSource.updateVendorProfile(vendorId, model);
    } catch (e) {
      throw Exception('Failed to update vendor profile: $e');
    }
  }

  @override
  Future<void> updateApprovalStatus(String vendorId, String status) async {
    try {
      await remoteDataSource.updateApprovalStatus(vendorId, status);
    } catch (e) {
      throw Exception('Failed to update approval status: $e');
    }
  }
}

