import '../repositories/promotion_repository.dart';

class IncrementPromotionClickUseCase {
  final PromotionRepository repository;
  IncrementPromotionClickUseCase(this.repository);

  Future<void> call(String promotionId) async {
    await repository.incrementClick(promotionId);
  }
}

