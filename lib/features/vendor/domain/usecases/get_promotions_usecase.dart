import '../repositories/promotion_repository.dart';
import '../entities/promotion_entity.dart';

class GetPromotionsUseCase {
  final PromotionRepository repository;
  GetPromotionsUseCase(this.repository);

  Future<List<PromotionEntity>> call() async {
    return await repository.getPromotions();
  }
}

