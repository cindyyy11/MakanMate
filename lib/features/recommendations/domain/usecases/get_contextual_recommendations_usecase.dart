import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/usecases/usecase.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for getting context-aware recommendations
/// 
/// This considers time, location, weather, occasion, etc.
class GetContextualRecommendationsUseCase
    implements
        UseCase<List<RecommendationEntity>,
            GetContextualRecommendationsParams> {
  final RecommendationRepository repository;

  GetContextualRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecommendationEntity>>> call(
    GetContextualRecommendationsParams params,
  ) async {
    return await repository.getContextualRecommendations(
      userId: params.userId,
      context: params.context,
      limit: params.limit,
    );
  }
}

/// Parameters for contextual recommendations
class GetContextualRecommendationsParams extends Equatable {
  final String userId;
  final RecommendationContextEntity context;
  final int limit;

  const GetContextualRecommendationsParams({
    required this.userId,
    required this.context,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, context, limit];
}

