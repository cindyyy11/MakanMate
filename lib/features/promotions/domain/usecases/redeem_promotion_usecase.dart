import '../user_promotion_repository.dart';

class RedeemPromotionUseCase {
  final UserPromotionRepository repository;
  
  const RedeemPromotionUseCase(this.repository);
  
  Future<void> call(String vendorId, String promotionId, String userId) {
    return repository.redeemPromotion(vendorId, promotionId, userId);
  }
}