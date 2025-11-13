import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/user/domain/repositories/user_repository.dart';

/// Use case for updating user preferences
class UpdateUserPreferencesUseCase {
  final UserRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateUserPreferencesParams params) async {
    return await repository.updateUserPreferences(
      userId: params.userId,
      cuisinePreferences: params.cuisinePreferences,
      dietaryRestrictions: params.dietaryRestrictions,
      spiceTolerance: params.spiceTolerance,
      culturalBackground: params.culturalBackground,
    );
  }
}

/// Parameters for updating user preferences
class UpdateUserPreferencesParams extends Equatable {
  final String userId;
  final Map<String, double>? cuisinePreferences;
  final List<String>? dietaryRestrictions;
  final double? spiceTolerance;
  final String? culturalBackground;

  const UpdateUserPreferencesParams({
    required this.userId,
    this.cuisinePreferences,
    this.dietaryRestrictions,
    this.spiceTolerance,
    this.culturalBackground,
  });

  @override
  List<Object?> get props => [
        userId,
        cuisinePreferences,
        dietaryRestrictions,
        spiceTolerance,
        culturalBackground,
      ];
}

