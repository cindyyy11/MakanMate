import '../repositories/promotion_repository.dart';
import '../entities/promotion_entity.dart';

class AddPromotionUseCase {
  final PromotionRepository repository;
  AddPromotionUseCase(this.repository);

  Future<void> call(PromotionEntity promotion) async {
    await repository.addPromotion(promotion);
  }
}

