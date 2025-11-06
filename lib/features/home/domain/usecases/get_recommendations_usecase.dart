import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRecommendationsUseCase {
  final RestaurantRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<List<RestaurantEntity>> call() async {
    return await repository.getRecommendations();
  }
}
