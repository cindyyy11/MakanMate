import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';
import '../models/menu_item_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remoteDataSource;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VendorRepositoryImpl({required this.remoteDataSource});

  String get vendorId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please log in.');
    }
    return user.uid;
  }

  @override
  Future<List<MenuItemEntity>> getMenuItems() async {
    return await remoteDataSource.getMenuItems(vendorId);
  }

  @override
  Future<void> addMenuItem(MenuItemEntity item) async {
    final model = MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      price: item.price,
      imageUrl: item.imageUrl,
      available: item.available,
      calories: item.calories,
    );
    await remoteDataSource.addMenuItem(vendorId, model);
  }

  @override
  Future<void> updateMenuItem(MenuItemEntity item) async {
    final model = MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      price: item.price,
      imageUrl: item.imageUrl,
      available: item.available,
      calories: item.calories,
    );
    await remoteDataSource.updateMenuItem(vendorId, model);
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await remoteDataSource.deleteMenuItem(vendorId, id);
  }
}
