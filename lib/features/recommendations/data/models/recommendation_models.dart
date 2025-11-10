import 'package:json_annotation/json_annotation.dart';
import 'package:makan_mate/core/base_model.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';

part 'recommendation_models.g.dart';

@JsonSerializable()
class RecommendationItem extends BaseModel {
  final String itemId;
  final double score;
  final String reason;
  final String algorithmType;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  const RecommendationItem({
    required this.itemId,
    required this.score,
    required this.reason,
    required this.algorithmType,
    required this.confidence,
    this.metadata = const {},
    required this.generatedAt,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$RecommendationItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecommendationItemToJson(this);

  RecommendationItem copyWith({
    String? itemId,
    double? score,
    String? reason,
    String? algorithmType,
    double? confidence,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
  }) {
    return RecommendationItem(
      itemId: itemId ?? this.itemId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      algorithmType: algorithmType ?? this.algorithmType,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

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
}

/// User interaction for building recommendation profile
@JsonSerializable()
class UserInteraction extends BaseModel {
  final String userId;
  final String itemId;
  final String interactionType;
  final double? rating;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const UserInteraction({
    required this.userId,
    required this.itemId,
    required this.interactionType,
    this.rating,
    required this.timestamp,
    this.context,
  });

  factory UserInteraction.fromJson(Map<String, dynamic> json) =>
      _$UserInteractionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserInteractionToJson(this);

  @override
  List<Object?> get props => [userId, itemId, interactionType, timestamp];
}

/// Context for recommendations
@JsonSerializable()
class RecommendationContext {
  final String userId;
  final DateTime timestamp;
  final String? timeOfDay;
  final String? dayOfWeek;
  final String? weather;
  final double? temperature;
  final Location? currentLocation;
  final String? occasion;
  final int? groupSize;

  const RecommendationContext({
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

  factory RecommendationContext.fromJson(Map<String, dynamic> json) =>
      _$RecommendationContextFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationContextToJson(this);
}
