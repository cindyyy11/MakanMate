import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/search/data/datasources/search_remote_datasource.dart';
import 'package:makan_mate/features/search/domain/entities/search_history_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_food_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SearchResultRestaurantEntity>>> searchRestaurants(
      String query) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final models = await remoteDataSource.searchRestaurants(query);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResultFoodEntity>>> searchFoods(
      String query) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final models = await remoteDataSource.searchFoods(query);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchHistoryEntity>>> getSearchHistory() async {
    if (!await networkInfo.isConnected) {
      // history still needs network, but you can change this if stored locally
      return Left(NetworkFailure());
    }

    try {
      final models = await remoteDataSource.getSearchHistory();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSearchHistory(String query) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.addSearchHistory(query);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
