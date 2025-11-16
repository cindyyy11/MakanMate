import '../repositories/promotion_repository.dart';

class IncrementPromotionRedeemedUseCase {
  final PromotionRepository repository;
  IncrementPromotionRedeemedUseCase(this.repository);

  Future<void> call(String promotionId) async {
    await repository.incrementRedeemed(promotionId);
  }
}

