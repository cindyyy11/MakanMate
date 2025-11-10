import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

abstract class VendorRemoteDataSource {
  Future<List<MenuItemModel>> getMenuItems(String vendorId);
  Future<void> addMenuItem(String vendorId, MenuItemModel item);
  Future<void> updateMenuItem(String vendorId, MenuItemModel item);
  Future<void> deleteMenuItem(String vendorId, String itemId);
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<List<MenuItemModel>> getMenuItems(String vendorId) async {
    final snapshot = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menus')
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => MenuItemModel.fromMap({
              'id': doc.id, // include Firestore document ID
              ...doc.data(),
            }))
        .toList();
  }

  @override
  Future<void> addMenuItem(String vendorId, MenuItemModel item) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menus')
        .add(item.toMap());
  }

  @override
  Future<void> updateMenuItem(String vendorId, MenuItemModel item) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menus')
        .doc(item.id)
        .update(item.toMap());
  }

  @override
  Future<void> deleteMenuItem(String vendorId, String itemId) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menus')
        .doc(itemId)
        .delete();
  }
}
