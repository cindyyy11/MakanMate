import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/usecases/usecase.dart';
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for getting personalized recommendations
/// 
/// Encapsulates the business logic for fetching recommendations
class GetRecommendationsUseCase
    implements UseCase<List<RecommendationEntity>, GetRecommendationsParams> {
  final RecommendationRepository repository;

  GetRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecommendationEntity>>> call(
    GetRecommendationsParams params,
  ) async {
    return await repository.getRecommendations(
      userId: params.userId,
      limit: params.limit,
      context: params.context,
    );
  }
}

/// Parameters for getting recommendations
class GetRecommendationsParams extends Equatable {
  final String userId;
  final int limit;
  final RecommendationContextEntity? context;

  const GetRecommendationsParams({
    required this.userId,
    this.limit = 10,
    this.context,
  });

  @override
  List<Object?> get props => [userId, limit, context];
}

