import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Parameters for rolling out winner
class RolloutWinnerParams {
  final String testId;
  final String winnerVariantId;

  const RolloutWinnerParams({
    required this.testId,
    required this.winnerVariantId,
  });
}

/// Use case for rolling out the winner variant to 100%
class RolloutWinnerUseCase {
  final AdminRepository repository;

  RolloutWinnerUseCase(this.repository);

  Future<Either<Failure, void>> call(RolloutWinnerParams params) async {
    return await repository.rolloutWinner(
      testId: params.testId,
      winnerVariantId: params.winnerVariantId,
    );
  }
}


