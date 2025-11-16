import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/search/domain/entities/search_history_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_food_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResultRestaurantEntity>>> searchRestaurants(
      String query);

  Future<Either<Failure, List<SearchResultFoodEntity>>> searchFoods(
      String query);

  Future<Either<Failure, List<SearchHistoryEntity>>> getSearchHistory();

  Future<Either<Failure, void>> addSearchHistory(String query);
}
