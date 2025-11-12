import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/user/domain/repositories/user_repository.dart';

/// Use case for updating behavioral patterns
class UpdateBehavioralPatternsUseCase {
  final UserRepository repository;

  UpdateBehavioralPatternsUseCase(this.repository);

  Future<Either<Failure, void>> call(
    UpdateBehavioralPatternsParams params,
  ) async {
    return await repository.updateBehavioralPatterns(
      userId: params.userId,
      behaviorPatterns: params.behaviorPatterns,
    );
  }
}

/// Parameters for updating behavioral patterns
class UpdateBehavioralPatternsParams extends Equatable {
  final String userId;
  final Map<String, double> behaviorPatterns;

  const UpdateBehavioralPatternsParams({
    required this.userId,
    required this.behaviorPatterns,
  });

  @override
  List<Object> get props => [userId, behaviorPatterns];
}
