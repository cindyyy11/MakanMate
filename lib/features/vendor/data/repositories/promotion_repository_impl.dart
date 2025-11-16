import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_datasource.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PromotionRepositoryImpl({required this.remoteDataSource});

  String get vendorId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please log in.');
    }
    return user.uid;
  }

  @override
  Future<List<PromotionEntity>> getPromotions() async {
    return await remoteDataSource.getPromotions(vendorId);
  }

  @override
  Future<List<PromotionEntity>> getPromotionsByStatus(String status) async {
    return await remoteDataSource.getPromotionsByStatus(vendorId, status);
  }

  @override
  Future<void> addPromotion(PromotionEntity promotion) async {
    final model = PromotionModel(
      id: promotion.id,
      vendorId: vendorId, 
      title: promotion.title,
      description: promotion.description,
      type: promotion.type,
      status: promotion.status,
      discountPercentage: promotion.discountPercentage,
      flatDiscountAmount: promotion.flatDiscountAmount,
      buyQuantity: promotion.buyQuantity,
      getQuantity: promotion.getQuantity,
      imageUrl: promotion.imageUrl,
      startDate: promotion.startDate,
      expiryDate: promotion.expiryDate,
      createdAt: promotion.createdAt,
      approvedAt: promotion.approvedAt,
      approvedBy: promotion.approvedBy,
    );
    await remoteDataSource.addPromotion(vendorId, model);
  }

  @override
  Future<void> updatePromotion(PromotionEntity promotion) async {
    final model = PromotionModel(
      id: promotion.id,
      title: promotion.title,
      description: promotion.description,
      type: promotion.type,
      status: promotion.status,
      discountPercentage: promotion.discountPercentage,
      flatDiscountAmount: promotion.flatDiscountAmount,
      buyQuantity: promotion.buyQuantity,
      getQuantity: promotion.getQuantity,
      imageUrl: promotion.imageUrl,
      startDate: promotion.startDate,
      expiryDate: promotion.expiryDate,
      createdAt: promotion.createdAt,
      approvedAt: promotion.approvedAt,
      approvedBy: promotion.approvedBy,
    );
    await remoteDataSource.updatePromotion(vendorId, model);
  }

  @override
  Future<void> deletePromotion(String id) async {
    await remoteDataSource.deletePromotion(vendorId, id);
  }

  @override
  Future<void> deactivatePromotion(String id) async {
    await remoteDataSource.deactivatePromotion(vendorId, id);
  }

  @override
  Future<void> incrementClick(String promotionId) async {
    await remoteDataSource.incrementClick(vendorId, promotionId);
  }

  @override
  Future<void> incrementRedeemed(String promotionId) async {
    await remoteDataSource.incrementRedeemed(vendorId, promotionId);
  }

  @override
  Future<void> incrementClickForUser(String vendorId, String promotionId) async {
    await remoteDataSource.incrementClick(vendorId, promotionId);
  }

  @override
  Future<void> incrementRedeemedForUser(String vendorId, String promotionId) async {
    await remoteDataSource.incrementRedeemed(vendorId, promotionId);
  }

  @override
  Stream<List<PromotionEntity>> watchApprovedPromotions() {
    return remoteDataSource.watchApprovedPromotions();
  }
}

