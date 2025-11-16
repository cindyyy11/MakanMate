import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';

class SearchRestaurantUsecase {
  final SearchRepository repository;

  SearchRestaurantUsecase(this.repository);

  Future<Either<Failure, List<SearchResultRestaurantEntity>>> call(
      String query) {
    return repository.searchRestaurants(query);
  }
}
