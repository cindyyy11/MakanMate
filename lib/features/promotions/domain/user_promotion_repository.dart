import '../../vendor/domain/entities/promotion_entity.dart';

abstract class UserPromotionRepository {
  Stream<List<PromotionEntity>> watchApprovedPromotions();
  Future<bool> hasUserRedeemed(String vendorId, String promotionId, String userId);
  Future<void> redeemPromotion(String vendorId, String promotionId, String userId);
}