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
