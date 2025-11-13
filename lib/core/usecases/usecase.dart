import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';

/// Base interface for all use cases
/// 
/// Follows clean architecture pattern where each use case
/// represents a single business operation
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

