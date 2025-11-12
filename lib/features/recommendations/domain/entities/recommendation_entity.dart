import 'package:equatable/equatable.dart';

/// Domain entity for a recommendation item
/// 
/// This represents the core business logic model for recommendations
class RecommendationEntity extends Equatable {
  final String itemId;
  final double score;
  final String reason;
  final String algorithmType;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  const RecommendationEntity({
    required this.itemId,
    required this.score,
    required this.reason,
    required this.algorithmType,
    required this.confidence,
    this.metadata = const {},
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        itemId,
        score,
        reason,
        algorithmType,
        confidence,
        metadata,
        generatedAt,
      ];

  RecommendationEntity copyWith({
    String? itemId,
    double? score,
    String? reason,
    String? algorithmType,
    double? confidence,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
  }) {
    return RecommendationEntity(
      itemId: itemId ?? this.itemId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      algorithmType: algorithmType ?? this.algorithmType,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

/// Context entity for generating recommendations
class RecommendationContextEntity extends Equatable {
  final String userId;
  final DateTime timestamp;
  final String? timeOfDay;
  final String? dayOfWeek;
  final String? weather;
  final double? temperature;
  final LocationEntity? currentLocation;
  final String? occasion;
  final int? groupSize;

  const RecommendationContextEntity({
    required this.userId,
    required this.timestamp,
    this.timeOfDay,
    this.dayOfWeek,
    this.weather,
    this.temperature,
    this.currentLocation,
    this.occasion,
    this.groupSize,
  });

  @override
  List<Object?> get props => [
        userId,
        timestamp,
        timeOfDay,
        dayOfWeek,
        weather,
        temperature,
        currentLocation,
        occasion,
        groupSize,
      ];
}

/// Location entity
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

