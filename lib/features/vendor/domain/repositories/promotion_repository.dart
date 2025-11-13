import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<List<PromotionEntity>> getPromotions();
  Future<List<PromotionEntity>> getPromotionsByStatus(String status);
  Future<void> addPromotion(PromotionEntity promotion);
  Future<void> updatePromotion(PromotionEntity promotion);
  Future<void> deletePromotion(String id);
  Future<void> deactivatePromotion(String id);
}

