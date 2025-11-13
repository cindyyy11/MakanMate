import '../repositories/promotion_repository.dart';
import '../entities/promotion_entity.dart';

class UpdatePromotionUseCase {
  final PromotionRepository repository;
  UpdatePromotionUseCase(this.repository);

  Future<void> call(PromotionEntity promotion) async {
    await repository.updatePromotion(promotion);
  }
}

