import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vendor_profile_entity.dart';
import '../models/vendor_profile_model.dart';
import '../models/menu_item_model.dart';

abstract class VendorRemoteDataSource {
  Future<VendorProfileEntity> getVendorProfile(String vendorId);
  Future<List<MenuItemEntity>> getVendorMenuItems(String vendorId);
  Future<List<VendorProfileEntity>> getAllApprovedVendors();
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  final FirebaseFirestore firestore;

  VendorRemoteDataSourceImpl(this.firestore);

  @override
  Future<VendorProfileEntity> getVendorProfile(String vendorId) async {
    final doc =
        await firestore.collection('vendors').doc(vendorId).get();

    final model = VendorProfileModel.fromFirestore(doc);
    return model.toEntity();
  }

  @override
  Future<List<MenuItemEntity>> getVendorMenuItems(String vendorId) async {
    final snapshot = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menu')
        .get();

    return snapshot.docs
        .map((d) => MenuItemModel.fromFirestore(d).toEntity())
        .toList();
  }

  @override
  Future<List<VendorProfileEntity>> getAllApprovedVendors() async {
    final snapshot = await firestore
        .collection('vendors')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    return snapshot.docs
        .map((d) => VendorProfileModel.fromFirestore(d).toEntity())
        .toList();
  }
}
