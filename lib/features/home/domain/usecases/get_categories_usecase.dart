import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetCategoriesUseCase {
  final RestaurantRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<RestaurantEntity>> call() async {
    return await repository.getCategories();
  }
}
