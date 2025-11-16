import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class WatchApprovedPromotionsUseCase {
  final PromotionRepository repository;
  const WatchApprovedPromotionsUseCase(this.repository);

  Stream<List<PromotionEntity>> call() {
    return repository.watchApprovedPromotions();
  }
}

