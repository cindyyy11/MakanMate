import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';

class AddSearchHistoryUsecase {
  final SearchRepository repository;

  AddSearchHistoryUsecase(this.repository);

  Future<Either<Failure, void>> call(String query) {
    return repository.addSearchHistory(query);
  }
}
