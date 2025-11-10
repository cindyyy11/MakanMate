import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/usecases/usecase.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for getting similar items
/// 
/// Used for "you might also like" features
class GetSimilarItemsUseCase
    implements UseCase<List<RecommendationEntity>, GetSimilarItemsParams> {
  final RecommendationRepository repository;

  GetSimilarItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecommendationEntity>>> call(
    GetSimilarItemsParams params,
  ) async {
    return await repository.getSimilarItems(
      itemId: params.itemId,
      limit: params.limit,
    );
  }
}

/// Parameters for similar items
class GetSimilarItemsParams extends Equatable {
  final String itemId;
  final int limit;

  const GetSimilarItemsParams({
    required this.itemId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [itemId, limit];
}

