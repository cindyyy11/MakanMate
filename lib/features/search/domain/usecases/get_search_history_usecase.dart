import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/search/domain/entities/search_history_entity.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';

class GetSearchHistoryUsecase {
  final SearchRepository repository;

  GetSearchHistoryUsecase(this.repository);

  Future<Either<Failure, List<SearchHistoryEntity>>> call() {
    return repository.getSearchHistory();
  }
}
