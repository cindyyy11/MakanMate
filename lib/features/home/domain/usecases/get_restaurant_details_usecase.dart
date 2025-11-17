import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class GetRestaurantDetailsUseCase {
  final RestaurantRepository repository;
  GetRestaurantDetailsUseCase(this.repository);

  Future<RestaurantEntity> call(String id) async {
    final result = await repository.getRestaurantById(id);
    return result;
  }
}
