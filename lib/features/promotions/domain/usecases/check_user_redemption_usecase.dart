import '../user_promotion_repository.dart';

class CheckUserRedemptionUseCase {
  final UserPromotionRepository repository;
  
  const CheckUserRedemptionUseCase(this.repository);
  
  Future<bool> call(String vendorId, String promotionId, String userId) {
    return repository.hasUserRedeemed(vendorId, promotionId, userId);
  }
}