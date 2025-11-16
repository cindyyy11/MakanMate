import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_food_entity.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';

class SearchFoodUsecase {
  final SearchRepository repository;

  SearchFoodUsecase(this.repository);

  Future<Either<Failure, List<SearchResultFoodEntity>>> call(String query) {
    return repository.searchFoods(query);
  }
}
