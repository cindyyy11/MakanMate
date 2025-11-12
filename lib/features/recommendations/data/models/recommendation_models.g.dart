// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationItem _$RecommendationItemFromJson(Map<String, dynamic> json) =>
    RecommendationItem(
      itemId: json['itemId'] as String,
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String,
      algorithmType: json['algorithmType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$RecommendationItemToJson(RecommendationItem instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'score': instance.score,
      'reason': instance.reason,
      'algorithmType': instance.algorithmType,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };

UserInteraction _$UserInteractionFromJson(Map<String, dynamic> json) =>
    UserInteraction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      interactionType: json['interactionType'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserInteractionToJson(UserInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'itemId': instance.itemId,
      'interactionType': instance.interactionType,
      'rating': instance.rating,
      'timestamp': instance.timestamp.toIso8601String(),
      'context': instance.context,
    };

RecommendationContext _$RecommendationContextFromJson(
  Map<String, dynamic> json,
) => RecommendationContext(
  userId: json['userId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  timeOfDay: json['timeOfDay'] as String?,
  dayOfWeek: json['dayOfWeek'] as String?,
  weather: json['weather'] as String?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  currentLocation: json['currentLocation'] == null
      ? null
      : Location.fromJson(json['currentLocation'] as Map<String, dynamic>),
  occasion: json['occasion'] as String?,
  groupSize: (json['groupSize'] as num?)?.toInt(),
);

Map<String, dynamic> _$RecommendationContextToJson(
  RecommendationContext instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'timestamp': instance.timestamp.toIso8601String(),
  'timeOfDay': instance.timeOfDay,
  'dayOfWeek': instance.dayOfWeek,
  'weather': instance.weather,
  'temperature': instance.temperature,
  'currentLocation': instance.currentLocation,
  'occasion': instance.occasion,
  'groupSize': instance.groupSize,
};
