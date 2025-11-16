import '../repositories/promotion_repository.dart';

class IncrementPromotionRedeemedForUserUseCase {
  final PromotionRepository repository;
  IncrementPromotionRedeemedForUserUseCase(this.repository);

  Future<void> call(String vendorId, String promotionId) async {
    await repository.incrementRedeemedForUser(vendorId, promotionId);
  }
}

