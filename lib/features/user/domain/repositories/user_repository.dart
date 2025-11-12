import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';

/// Repository interface for user profile management (Domain layer)
abstract class UserRepository {
  /// Get user by ID
  Future<Either<Failure, UserEntity>> getUser(String userId);

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  /// Update user preferences
  Future<Either<Failure, void>> updateUserPreferences({
    required String userId,
    Map<String, double>? cuisinePreferences,
    List<String>? dietaryRestrictions,
    double? spiceTolerance,
    String? culturalBackground,
  });

  /// Update behavioral patterns
  Future<Either<Failure, void>> updateBehavioralPatterns({
    required String userId,
    required Map<String, double> behaviorPatterns,
  });
}

