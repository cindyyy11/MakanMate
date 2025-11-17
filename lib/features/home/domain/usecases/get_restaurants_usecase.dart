import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class GetRestaurantsUseCase {
  final RestaurantRepository repository;
  GetRestaurantsUseCase(this.repository);

  Future<List<RestaurantEntity>> call() async {
    final result = await repository.getRestaurants(); 
    return result; 
  }
}
