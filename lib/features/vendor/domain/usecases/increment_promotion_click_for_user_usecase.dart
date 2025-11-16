import '../repositories/promotion_repository.dart';

class IncrementPromotionClickForUserUseCase {
  final PromotionRepository repository;
  IncrementPromotionClickForUserUseCase(this.repository);

  Future<void> call(String vendorId, String promotionId) async {
    await repository.incrementClickForUser(vendorId, promotionId);
  }
}

