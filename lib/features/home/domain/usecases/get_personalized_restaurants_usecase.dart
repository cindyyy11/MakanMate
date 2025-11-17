import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class GetPersonalizedRestaurantsUseCase {
  final RestaurantRepository repository;
  GetPersonalizedRestaurantsUseCase(this.repository);

  Future<List<RestaurantEntity>> call(Map<String, dynamic> prefs) async {
    final result = await repository.getPersonalizedRestaurants(prefs);
    return result;
  }
}
