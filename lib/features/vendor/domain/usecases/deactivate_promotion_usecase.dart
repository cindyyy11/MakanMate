import '../repositories/promotion_repository.dart';

class DeactivatePromotionUseCase {
  final PromotionRepository repository;
  DeactivatePromotionUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deactivatePromotion(id);
  }
}

