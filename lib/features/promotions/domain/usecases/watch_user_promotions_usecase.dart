import '../user_promotion_repository.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';

class WatchUserPromotionsUseCase {
  final UserPromotionRepository repository;
  const WatchUserPromotionsUseCase(this.repository);

  Stream<List<PromotionEntity>> call() {
    return repository.watchApprovedPromotions();
  }
}
