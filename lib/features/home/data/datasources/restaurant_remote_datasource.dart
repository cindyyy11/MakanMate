import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../vendor/data/models/vendor_profile_model.dart';
import '../../../vendor/data/models/menu_item_model.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantEntity>> getRestaurants();
  Future<RestaurantEntity> getRestaurantById(String vendorId);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<RestaurantEntity>> getRestaurants() async {
    final snapshot = await firestore
        .collection('vendors')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    final List<RestaurantEntity> restaurants = [];

    for (final doc in snapshot.docs) {
      final vendorModel = VendorProfileModel.fromFirestore(doc);

      final menuSnapshot = await firestore
          .collection('vendors')
          .doc(doc.id)
          .collection('menu')
          .get();

      final menuModels =
          menuSnapshot.docs.map((d) => MenuItemModel.fromFirestore(d)).toList();

      final restaurantModel = RestaurantModel(
        vendorModel: vendorModel,
        menuItemModels: menuModels,
      );

      restaurants.add(restaurantModel.toEntity());
    }

    return restaurants;
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String vendorId) async {
    final vendorDoc =
        await firestore.collection('vendors').doc(vendorId).get();
    final vendorModel = VendorProfileModel.fromFirestore(vendorDoc);

    final menuSnapshot = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('menu')
        .get();

    final menuModels =
        menuSnapshot.docs.map((d) => MenuItemModel.fromFirestore(d)).toList();

    final restaurantModel = RestaurantModel(
      vendorModel: vendorModel,
      menuItemModels: menuModels,
    );

    return restaurantModel.toEntity();
  }
}
