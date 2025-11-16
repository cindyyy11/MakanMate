import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';
import '../../domain/user_promotion_repository.dart';
import '../datasources/user_promotion_remote_datasource.dart';

class UserPromotionRepositoryImpl implements UserPromotionRepository {
  final UserPromotionRemoteDataSource remoteDataSource;

  UserPromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<PromotionEntity>> watchApprovedPromotions() {
    return remoteDataSource.watchApprovedPromotions();
  }

  @override
  Future<bool> hasUserRedeemed(String vendorId, String promotionId, String userId) {
    return remoteDataSource.hasUserRedeemed(vendorId, promotionId, userId);
  }

  @override
  Future<void> redeemPromotion(String vendorId, String promotionId, String userId) {
    return remoteDataSource.redeemPromotion(vendorId, promotionId, userId);
  }
}