import 'package:equatable/equatable.dart';

/// Feature flag configuration
class FeatureFlag extends Equatable {
  final String id;
  final String name; // AR Food Hunt, Voice Search, etc.
  final String key; // ar_food_hunt, voice_search
  final bool isEnabled;
  final int rolloutPercentage; // 0-100
  final List<String> targetUserIds; // Specific users if needed
  final List<String> targetRegions; // Specific regions if needed
  final DateTime? enabledAt;
  final DateTime? disabledAt;
  final String? enabledBy;
  final Map<String, dynamic> metadata;

  const FeatureFlag({
    required this.id,
    required this.name,
    required this.key,
    this.isEnabled = false,
    this.rolloutPercentage = 0,
    this.targetUserIds = const [],
    this.targetRegions = const [],
    this.enabledAt,
    this.disabledAt,
    this.enabledBy,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        name,
        key,
        isEnabled,
        rolloutPercentage,
        targetUserIds,
        targetRegions,
        enabledAt,
        disabledAt,
        enabledBy,
        metadata,
      ];
}


