import '../repositories/promotion_repository.dart';
import '../entities/promotion_entity.dart';

class GetPromotionsByStatusUseCase {
  final PromotionRepository repository;
  GetPromotionsByStatusUseCase(this.repository);

  Future<List<PromotionEntity>> call(String status) async {
    return await repository.getPromotionsByStatus(status);
  }
}

