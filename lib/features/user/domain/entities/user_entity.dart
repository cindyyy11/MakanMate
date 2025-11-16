import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';

/// User entity (Domain layer)
/// Represents user profile and preferences
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final bool isBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedUntil;
  final String? bannedBy;
  final String? profileImageUrl;
  final List<String> dietaryRestrictions;
  final Map<String, double> cuisinePreferences;
  final double spiceTolerance;
  final String culturalBackground;
  final Location currentLocation;
  final Map<String, double> behaviorPatterns;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    required this.isVerified,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.bannedUntil,
    this.bannedBy,
    this.profileImageUrl,
    this.dietaryRestrictions = const [],
    this.cuisinePreferences = const {},
    this.spiceTolerance = 0.5,
    this.culturalBackground = 'mixed',
    required this.currentLocation,
    this.behaviorPatterns = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    profileImageUrl,
    dietaryRestrictions,
    cuisinePreferences,
    isBanned,
    banReason,
    bannedAt,
    bannedUntil,
    bannedBy,
    spiceTolerance,
    culturalBackground,
    currentLocation,
    behaviorPatterns,
    createdAt,
    updatedAt,
    isVerified,
  ];
}
